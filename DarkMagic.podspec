Pod::Spec.new do |s|
  s.name             = "DarkMagic"
  s.summary          = "A short description of DarkMagic."
  s.version          = "0.0.4"
  s.homepage         = "github.com/Strobocop/DarkMagic"
  s.license          = 'MIT'
  s.author           = { "Brian Strobach" => "brian@appsaurus.io" }
  s.source           = {
    :git => "https://github.com/appsaurus/DarkMagic.git",
    :tag => s.version.to_s
  }

  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.2'
  s.watchos.deployment_target = "3.0"

  s.requires_arc = true
  s.ios.source_files = 'Sources/{iOS,Shared}/**/*'
  s.tvos.source_files = 'Sources/{iOS,tvOS,Shared}/**/*'
  s.osx.source_files = 'Sources/{macOS,Shared}/**/*'
  s.watchos.source_files = 'Sources/{watchOS,Shared}/**/*'

end
