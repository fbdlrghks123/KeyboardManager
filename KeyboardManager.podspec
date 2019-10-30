Pod::Spec.new do |s|
  s.name             = 'KeyboardManager'
  s.version          = '0.1.0'
  s.summary          = 'PodRegister'
  s.description      = <<-DESC
                      PodRegister
                      DESC
  s.homepage         = 'https://github.com/fbdlrghks123/KeyboardManager'
  s.screenshots      = '[IMAGE URL 1]', '[IMAGE URL 2]'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '[ACCOUNT]' => '[E-MAIL]' }
  s.source           = { :git => 'https://github.com/fbdlrghks123/KeyboardManager.git', :commit => "6ca98f66100b156331210621652a32e1f219c042" }
  s.ios.deployment_target = '10.0'
  s.swift_versions = '5.0'
  s.source_files = 'Sources/*.swift'
end