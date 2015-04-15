Pod::Spec.new do |s|
  s.name             = "ECKeychain"
  s.version          = "1.0.1"
  s.summary          = "Simple interface for managing items in Keychain (iOS and Mac)."
  s.homepage         = "https://github.com/ecaselles/eckeychain"
  s.license          = 'MIT'
  s.author           = { "Edu Caselles" => "edu@casell.es" }
  s.source           = { :git => "https://github.com/ecaselles/eckeychain.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.source_files = 'ECKeychain/**/*'

  s.public_header_files = 'ECKeychain/**/*.h'
  s.frameworks = 'Foundation'
end
