Pod::Spec.new do |spec|
  spec.name = 'QueryKit'
  spec.version = '0.13.0'
  spec.summary = 'A simple type-safe Core Data query language.'
  spec.homepage = 'http://querykit.org/'
  spec.license = { :type => 'BSD', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'kyle@fuller.li' }
  spec.social_media_url = 'https://twitter.com/QueryKit'
  spec.source = { :git => 'https://github.com/QueryKit/QueryKit.git', :tag => "#{spec.version}" }
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = '9.0'
  spec.frameworks = 'CoreData'
  spec.source_files = 'QueryKit/*.swift'
end

