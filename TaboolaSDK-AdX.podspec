Pod::Spec.new do |s|
  s.name             = 'TaboolaSDK-AdX'
  s.version          = '1.3'
  s.summary          = 'TaboolaSDK adapter for AdX'
  s.description      = 'The Taboola Mobile Ads SDK allows you to maximize monetization for your iOS and Android apps with Taboola ads.'

  s.homepage         = 'https://www.taboola.com'
  s.license          = { :type => 'Taboola Mobile SDK License', :file => 'LICENSE' }
  s.author           = { 'Taboola' => 'mobile-sdk@taboola.com' }
  s.source           = { :git => 'https://github.com/taboola/ios-adx.git', :tag => s.version.to_s }

  s.platform         = :ios, '13.0'
  s.swift_versions   = ['5.0']
  
  s.static_framework = true
  s.source_files     = 'TBLAdxPlugin/**/*.*'
  s.public_header_files = 'TBLAdxPlugin/**/*.h'

  s.dependency 'Google-Mobile-Ads-SDK', '~> 13.0'
end
