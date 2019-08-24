Pod::Spec.new do |s|
  s.name        = 'SourcererRenderer'
  s.version     = '0.2.0'
  s.summary     = 'Pure-Swift meta-programming (Renderer)'

  s.description = <<-DESC
    Proof-of-concept pure Swift code-generator that runs on top of [Sourcery](https://github.com/krzysztofzablocki/Sourcery).
  DESC

  s.homepage    = 'https://github.com/hectr/swift-sourcerer'
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.author      = { 'Hèctor Marquès' => 'h@mrhector.me' }
  s.source      = { :git => 'https://github.com/hectr/swift-sourcerer.git', :tag => s.version.to_s }

  s.swift_version         = '5.0'
  s.osx.deployment_target = '10.13'

  s.static_framework = true

  s.source_files = 'Sources/SourcererRenderer/**/*.swift'

  s.dependency 'SourcererTypes'
end
