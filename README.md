# Clean architecture with [RxSwift](https://github.com/ReactiveX/RxSwift)

## Contibutions are welcome and highly appreciated!!
You can do this by:

- open an issue to discuss current solution, ask question, propose your solution etc. (also English is not my native language so if you think that something can be corrected please open a PR 😊)
- open PR if you want to fix bugs or improve something

##High level overview
![](Architecture/Modules.png)

#### Domain 

The `Domain` is basically what is your App about and what it can do (Entities, UseCase etc.) **It does not depend on UIKit or any persistent framework**, it doesn't have implementation apart from entities

#### Platform

The `Platform` is a concrete implementation of the `Domain` in a specific platform like iOS. It does hide all implementation details. For example Database implementation whether it is CoreData, Realm, SQLite etc.

#### Application
The `Application` is responsible for delivering information to the user and handling user input. It can be implemented with any delivery pattern e.g (MVVM, MVC, MVP). It is place where you have your `UIView`s and `UIViewController`s. As you will see from the example app `ViewControllers` are completely independant on the `Platform` the only responsobility of view controller is to "bind" UI and Domain to make things happened. In fact in the current example we are using the same view controller which binds to the Platform with Realm or CoreData storage under the hood.


##Detail overiview
![](Architecture/Modules Details.png)
 
The `Domain`, `Platform` and `Aplication` modules are enforsed by being seperate targets in the App wich is going to help us take advantage of `internal` access layer in Swift to prevent exposure of types which are not supposed to be exposed. Additionaly, in this way we can be very explicit regarding usage of modules: The Aplication imports the Platform and Domain; the Platform imports the Domain; The Domain doesn't know about the Platform and Application.

#### Domain

Entities are implemented as Swift value types

```swift
public struct Post {
    public let uid: String
    public let createDate: Date
    public let updateDate: Date
    public let title: String
    public let content: String
}
```

UseCases are protocols which describes very specific functionality.

```swift

public protocol AllPostsUseCase {
    func posts() -> Observable<[Post]>
}

public protocol SavePostUseCase {
    func save(post: Post) -> Observable<Void>
}

```
The `UseCaseProvider` is a [service locator](https://en.wikipedia.org/wiki/Service_locator_pattern) in a current example it helps to hide the concrete implementation of use cases

#### Platform

We have to define Platform level counterparts for out Domain object and usualy we can't use Domain structs directly, due to requirements of DB frameworks: (e.g. CoreData, Realm requires entities to be subclass of their root class). 

```swift
final class CDPost: NSManagedObject {
	@NSManaged public var uid: String?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var updateDate: NSDate?
}

final class RMPost: Object {
    dynamic var uid: String = ""
    dynamic var createDate: NSDate = NSDate()
    dynamic var updateDate: NSDate = NSDate()
    dynamic var title: String = ""
    dynamic var content: String = ""
}

```

The `Platform` also contains concrete implementations of your use cases, repositories or any services that are defined in the `Domain`

```swift
final class SavePostUseCase: Domain.SavePostUseCase {
    private let repository: AbstractRepository<Post>

    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }

    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }
}

final class Repository<T: CoreDataRepresentable>: AbstractRepository<T> where T == T.CoreDataType.DomainType {
    private let context: NSManagedObjectContext
    private let scheduler: ContextScheduler

    init(context: NSManagedObjectContext) {
        self.context = context
        self.scheduler = ContextScheduler(context: context)
    }

    override func query(with predicate: NSPredicate? = nil,
                        sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[T]> {
        let request = T.CoreDataType.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return context.rx.entities(fetchRequest: request)
            .mapToDomain()
            .subscribeOn(scheduler)
    }

    override func save(entity: T) -> Observable<Void> {
        return entity.sync(in: context)
            .mapToVoid()
            .concat(context.rx.save())
            .skip(1) //We dont want to receive event for sync
            .subscribeOn(scheduler)
    }
}

```
As you can see concrete implementations are internal, because we dont want to expose our dependecies. The only thing we expose in the current example from the `Platform` is the `ServiceLocator`

```swift
public final class ServiceLocator: Domain.ServiceLocator {
    public static let shared = ServiceLocator()

    private let coreDataStack = CoreDataStack()
    private let postRepository: Repository<Post>

  	 private init() {
        postRepository = Repository<Post>(context: coreDataStack.context)
    }

    public func getAllPostsUseCase() -> Domain.AllPostsUseCase {
        return CDAllPostsUseCase(repository: postRepository)
    }

    public func getCreatePostUseCase() -> Domain.SavePostUseCase {
        return CDSavePostUseCase(repository: postRepository)
    }
}
```

####Aplication

In the current example the `Aplication` implemented with [MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel) pattern with havy use of [RxSwift](https://github.com/ReactiveX/RxSwift), which makes binding very easy.

![](Architecture/MVVMPattern.png)

Where the `ViewModel` performs pure transformation of a user `Input` to the `Output`

```swift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
```


```swift
final class PostsViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let createPostTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }
    struct Output {
        let fetching: Driver<Bool>
        let posts: Driver<[Post]>
        let createPost: Driver<Void>
        let selectedPost: Driver<Post>
        let error: Driver<Error>
    }
    
    private let useCase: AllPostsUseCase
    private let navigator: PostsNavigator
    
    init(useCase: AllPostsUseCase, navigator: PostsNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
       ......
    }
```

The `ViewModel` can be injected into the `ViewController` via a property injection or an initializer. In the current example this is done by the `Navigator`.

```swift

protocol PostsNavigator {
    func toCreatePost()
    func toPost(_ post: Post)
    func toPosts()
}

class DefaultPostsNavigator: PostsNavigator {
    private let storyBoard: UIStoryboard
    private let navigationController: UINavigationController
    private let services: ServiceLocator
    
    init(services: ServiceLocator,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.services = services
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
    
    func toPosts() {
        let vc = storyBoard.instantiateViewController(ofType: PostsViewController.self)
        vc.viewModel = PostsViewModel(useCase: services.getAllPostsUseCase(),
                                      navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    ....
}

class PostsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel: PostsViewModel!
    
    ...
}
```

###Example

The example app is a Post/TODOs app which uses `Realm` and `CoreData` at the same time as a prove of that the Application level is not dependant on the Platform level implementation details.

| CoreData | Realm |
| -------- | ----- |
|![](Architecture/CoreData.gif) | ![](Architecture/Realm.gif) |


###TODO:

* add tests 
* add [MVP](https://en.wikipedia.org/wiki/Model–view–presenter) example
* [Redux](http://redux.js.org) example??

###Links
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [Robert C Martin - Clean Architecture and Design](https://www.youtube.com/watch?v=Nsjsiz2A9mg)
* [Cycle.js](https://cycle.js.org)
* [ViewModel](https://medium.com/@SergDort/viewmodel-in-rxswift-world-13d39faa2cf5#.qse37r6jw) in Rx world
