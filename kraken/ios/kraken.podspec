#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint kraken_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kraken'
  s.version          = '0.6.3'
  s.summary          = 'A high-performance, web standards-compliant rendering engine.'
  s.description      = <<-DESC
A high-performance, web standards-compliant rendering engine.
                       DESC
  s.homepage         = 'https://openkraken.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KrakenTeam' => 'openkraken@alibaba-inc.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.vendored_frameworks = 'kraken_bridge.xcframework'
  s.prepare_command = 'bash prepare.sh'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
