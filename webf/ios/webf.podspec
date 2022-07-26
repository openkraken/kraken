#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'webf'
  s.version          = '0.1.0'
  s.summary          = 'A W3C standard compliant Web rendering engine based on Flutter.'
  s.description      = <<-DESC
  A W3C standard compliant Web rendering engine based on Flutter.
                       DESC
  s.homepage         = 'https://openwebf.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'OpenWebF' => 'dongtiangche@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.vendored_frameworks = 'webf_bridge.xcframework', 'quickjs.xcframework'
  s.prepare_command = 'bash prepare.sh'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
