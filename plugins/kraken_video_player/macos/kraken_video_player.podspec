#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint kraken_video_player.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kraken_video_player'
  s.version          = '0.0.1'
  s.summary          = 'Kraken Video Player'
  s.description      = <<-DESC
Kraken Video Player
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'chenghuai.dtc' => 'chenghuai.dtc@alibaba-inc.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
