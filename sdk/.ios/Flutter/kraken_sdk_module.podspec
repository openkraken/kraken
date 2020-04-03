Pod::Spec.new do |s|
  s.name                  = 'kraken_sdk_module'
  s.version               = '0.0.1'
  s.summary               = ''
  s.description           = ''
  s.homepage              = 'https://rax.js.org/kraken'
  s.license               = { :type => 'MIT' }
  s.author                = { 'KrakenTeam' => 'rax-public@alibaba-inc.com' }
  s.source                = { :path => '.' }
  s.ios.deployment_target = '8.0'
  s.vendored_frameworks   = 'App.framework'
  s.dependency 'Flutter'
end
