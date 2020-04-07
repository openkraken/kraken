Pod::Spec.new do |s|
  s.name             = 'KrakenSDK'
  s.version          = '@VERSION@'
  s.summary          = 'Kraken SDK'
  s.description      = <<-DESC
New generation rendering framework.
                       DESC

  s.homepage         = 'https://rax.js.org/kraken'
  s.license          = { :type => 'MIT' }
  s.author           = { 'KrakenTeam' => 'rax-public@alibaba-inc.com' }
  s.source           = { :git => 'git@gitlab.alibaba-inc.com:kraken/sdk-pod-distribution.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.static_framework = true

  p = Dir::open("./")
  arr = Array.new
  p.each do |f|
    if f.end_with?('.framework')
      arr.push(f)
    end
  end

  s.ios.vendored_frameworks = arr
end
