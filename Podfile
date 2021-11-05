# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
inhibit_all_warnings!

def rx_swift
    pod 'RxSwift'
end

def rx_cocoa
    pod 'RxCocoa'
end

def test_pods
    pod 'RxTest'
    pod 'RxBlocking'
    pod 'Nimble'
end


target 'CleanArchitectureRxSwift' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  rx_cocoa
  rx_swift
  pod 'QueryKit'
  target 'CleanArchitectureRxSwiftTests' do
    inherit! :search_paths
    test_pods
  end

end

target 'CoreDataPlatform' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  rx_swift
  pod 'QueryKit'
  target 'CoreDataPlatformTests' do
    inherit! :search_paths
    test_pods
  end

end

target 'Domain' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  rx_swift

  target 'DomainTests' do
    inherit! :search_paths
    test_pods
  end

end

target 'NetworkPlatform' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    rx_swift
    pod 'Alamofire'
    pod 'RxAlamofire'

    target 'NetworkPlatformTests' do
        inherit! :search_paths
        test_pods
    end
    
end

target 'RealmPlatform' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  rx_swift
  pod 'RxRealm'
  pod 'QueryKit'
  pod 'RealmSwift'
  pod 'Realm'

  target 'RealmPlatformTests' do
    inherit! :search_paths
    test_pods
  end

end
