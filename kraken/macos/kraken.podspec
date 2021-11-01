#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint kraken_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kraken'
  s.version          = '0.9.0'
  s.summary          = 'A high-performance, web standards-compliant rendering engine.'
  s.description      = <<-DESC
A high-performance, web standards-compliant rendering engine.
                       DESC
  s.homepage         = 'https://openkraken.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KrakenTeam' => 'openkraken@alibaba-inc.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'
  s.vendored_libraries = 'libkraken.dylib', 'libquickjs.dylib'
  s.prepare_command = 'bash prepare.sh'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
