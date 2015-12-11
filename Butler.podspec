Pod::Spec.new do |s|
  s.name = 'Butler'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Butler does things that you could do but dont want to'
  s.homepage = 'https://github.com/nickoneill/Butler'
  s.social_media_url = 'https://twitter.com/objctoswift'
  s.authors = { "Nick O'Neill" => 'nick.oneill@gmail.com' }
  s.source = { :git => 'https://github.com/nickoneill/Butler.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Butler/*.swift'

  s.requires_arc = true
end

