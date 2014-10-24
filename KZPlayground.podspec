Pod::Spec.new do |s|
  s.name             = "KZPlayground"
  s.version          = "0.1.1"
  s.summary          = "Playgrounds but for Objective-C, with some extra coolnes."
  s.description      = <<-DESC
                       We all love Swift playgrounds, they are really great,
but since most of us still write Objective-C code, why not get benefits of rapid development with Objective-C Plagrounds?
Fast robust interations make it easy to prototype custom UI/Algorithms or even learn Objective-C or some new API.
                       DESC
  s.homepage         = "https://github.com/krzysztofzablocki/KZPlayground"
  s.license          = 'MIT'
  s.author           = { "Krzysztof Zablocki" => "krzysztof.zablocki@me.com" }
  s.source           = { :git => "https://github.com/krzysztofzablocki/KZPlayground.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/merowing_'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.h', 'Pod/Classes/**/*.m'
  s.resources = ['Pod/Assets/*']

  s.dependency 'dyci', '~> 0.1.5.6'
end
