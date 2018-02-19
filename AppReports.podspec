Pod::Spec.new do |s|

  s.name         = "AppReports"
  s.version      = "1.0.3"
  s.summary      = "Reports events and errors helper class"

  s.description  = <<-DESC
Reports events and errors helper class.
Write and use for swift.
You can write helper on swift with support objc as wrapper for this class.
                   DESC

  s.homepage     = "https://github.com/ProVir/AppReports"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "ViR (Vitaliy Korotkiy)" => "admin@provir.ru" }
  s.source       = { :git => "https://github.com/ProVir/AppReports.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files        = 'AppReports/*.{h,swift}'
  s.public_header_files = 'AppReports/*.h'

end
