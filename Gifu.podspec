Pod::Spec.new do |s|
  s.name = "Gifu"
  s.version = "3.2.0"
  s.summary = "High-performance animated GIF support for iOS "
  s.homepage = "https://github.com/kaishin/Gifu"
  s.social_media_url = "http://twitter.com/kaishin"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Reda Lemeden" => "git@kaishin.haz.email" }
  s.source = { :git => "https://github.com/kaishin/Gifu.git", :tag => "v#{s.version}", :submodules => true }
  s.platform = :ios, "9.0"
  s.platform = :tvos, "9.0"
  s.ios.source_files = "Source/**/*.{h,swift}"
  s.tvos.source_files = "Source/**/*.{h,swift}"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
end
