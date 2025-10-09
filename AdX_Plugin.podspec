Pod::Spec.new do |s|
  s.name             = 'TaboolaSDK_AdX_Adapter'
  s.version          = '1.0-beta-1'
  s.summary          = 'TaboolaSDK adapter for AdX'
  s.description      = 'The Taboola Mobile Ads SDK allows you to maximize monetization for your iOS and Android apps with Taboola ads.'

  s.homepage         = 'https://www.taboola.com'
  s.license          = { :type => 'Taboola Mobile SDK License', :file => 'LICENSE' }
  s.author           = { 'Taboola' => 'mobile-sdk@taboola.com' }
  s.source           = { :git => 'https://github.com/taboola/ios-sdk-adx-adapter', :tag => s.version.to_s }

  s.platform         = :ios, '12.0'

  s.static_framework = true
  s.source_files = 'TBLAdxPlugin/**/*.*'
  s.public_header_files = 'TBLAdxPlugin/**/*.h'

  s.dependency 'Google-Mobile-Ads-SDK', '~> 12.0'
end
