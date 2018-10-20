Pod::Spec.new do |s|
  s.name        = 'SourceryRuntime'
  s.version     = '0.0.1'
  s.summary     = 'Pure-Swift meta-programming (SourceryRuntime)'

  s.description = <<-DESC
    Proof-of-concept pure Swift code-generator that runs on top of [Sourcery](https://github.com/krzysztofzablocki/Sourcery).
  DESC

  s.homepage    = 'https://github.com/krzysztofzablocki/Sourcery'
  s.license     = 'MIT'
  s.author      = 'Krzysztof Zabłocki'
  s.source      = { :path => '.' }

  s.osx.deployment_target = '10.13'

  s.static_framework = true

  s.source_files = 'Vendor/SourceryRuntime/**/*'

  s.prepare_command = <<-CMD
    ./install_sourcery_runtime.sh
  CMD
end
