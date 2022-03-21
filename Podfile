# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
platform :ios, '11.0'
inhibit_all_warnings!
install! 'cocoapods',
  :warn_for_unused_master_specs_repo => false
  
def rx_swift
    pod 'RxSwift', '~> 6.5.0'
end

def rx_cocoa
    pod 'RxCocoa', '~> 6.5.0'
end

def test_pods
    pod 'RxTest', '~> 6.5.0'
    pod 'RxBlocking', '~> 6.5.0'
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
