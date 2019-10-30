Pod::Spec.new do |s|
  s.name             = 'SimpleKeyboardManager'
  s.version          = '0.1.1'
  s.summary          = 'PodRegister'
  s.description      = <<-DESC
                      0.1.1 Update
                      DESC
  s.homepage         = 'https://github.com/fbdlrghks123/SimpleKeyboardManager.git'
  s.license          = { :type => "MIT", :file => "/Users/ryuickhwan/Desktop/KeyboardManager/LICENSE" }
  s.author           = { 'fbdlrghks123' => 'fbdlrghks123@naver.com' }
  s.source           = { :git => 'https://github.com/fbdlrghks123/SimpleKeyboardManager.git', :tag => "#{s.version}" }
  s.ios.deployment_target = '10.0'
  s.platform        = :ios, "10.0"
  s.swift_version = '5.0'
  s.source_files = 'Sources/*'
end