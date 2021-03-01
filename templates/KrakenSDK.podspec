Pod::Spec.new do |s|
  s.name             = 'KrakenSDK'
  s.version          = '@VERSION@'
  s.summary          = 'Kraken SDK'
  s.description      = <<-DESC
  A high-performance, web standards-compliant rendering engine.
                       DESC

  s.homepage         = 'https://github.com/openkraken/kraken'
  s.license          = { :type => 'Apache License 2.0' }
  s.author           = { 'Kraken Team' => 'rax-public@alibaba-inc.com' }
  s.source           = { :git => 'git@github.com:openkraken/kraken.git', :tag => s.version.to_s }
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
