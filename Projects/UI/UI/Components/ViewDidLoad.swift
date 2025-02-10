import SwiftUI

public extension View {
    func onViewDidLoad(didLoad: @escaping () -> Void) -> some View {
        modifier(ViewDidLoad(didLoad: didLoad))
    }
}

struct ViewDidLoad: ViewModifier {
    @StateObject var model: Model
    
    init(didLoad: @escaping () -> Void) {
        _model = StateObject(wrappedValue: Model(didLoad: didLoad))
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if model.didCallAppear == false {
                model.didCallAppear = true
                model.didLoad()
            }
        }
    }
    
    final class Model: ObservableObject {
        var didCallAppear = false
        let didLoad: () -> Void
        
        init(didLoad: @escaping () -> Void) {
            self.didLoad = didLoad
        }
    }
}
