Pod::Spec.new do |s|
  s.name = "Gifu"
  s.version = "3.4.1"
  s.summary = "High-performance animated GIF support for iOS "
  s.homepage = "https://github.com/kaishin/Gifu"
  s.social_media_url = "http://twitter.com/kaishin"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Reda Lemeden" => "git@redalemeden.com" }
  s.source = { :git => "https://github.com/kaishin/Gifu.git", :tag => "v#{s.version}", :submodules => true }
  s.platform = :ios, "9.0"
  s.platform = :tvos, "9.0"
  s.swift_versions = ["5.0", "5.1", "5.2", "5.3", "5.4"]
  s.ios.source_files = "Sources/**/*.{h,swift}"
  s.tvos.source_files = "Sources/**/*.{h,swift}"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
end
