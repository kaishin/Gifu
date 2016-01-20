Pod::Spec.new do |s|
  s.name = "Gifu"
  s.version = "1.0.1"
  s.summary = "Highly performant animated GIF support for iOS "
  s.homepage = "https://github.com/kaishin/gifu"
  s.social_media_url = "http://twitter.com/kaishin"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Reda Lemeden" => "git@kaishin.haz.email" }
  s.source = { :git => "https://github.com/kaishin/gifu.git", :tag => "v#{s.version}", :submodules => true }
  s.platform = :ios, "8.0"
  s.ios.source_files = "Source/**/*.{h,swift}", "Carthage/Checkouts/Runes/Source/Runes.swift"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
end
