Pod::Spec.new do |s|
  s.name             = 'sourcerer'
  s.version          = '0.1.0'
  s.summary          = 'Swift source code metrics generator'
  s.description = <<-DESC
  Proof-of-concept pure Swift code-generator that runs on top of [Sourcery](https://github.com/krzysztofzablocki/Sourcery).
  DESC
  s.homepage         = 'https://github.com/hectr/swift-sourcerer'
  s.license          = 'MIT'
  s.author           = { 'Hèctor Marquès' => 'h@mrhector.me' }
  s.social_media_url = "https://twitter.com/elnetus"
  s.source           = { :http => "#{s.homepage}/releases/download/#{s.version}/sourcerer.zip" }
  s.preserve_paths   = '*'
  s.exclude_files    = '**/file.zip'
end
