Pod::Spec.new do |s|
  s.name         = "MetadataShortenerApi"
  s.version      = "0.1.0"
  s.summary      = "Swift wrapper for the metadata shorterner needed to generate metadata hash or proof for extrinsic"
  s.homepage     = "https://github.com/novasamatech/metadata-shortener-ios"
  s.license      = 'MIT'
  s.author       = {'Ruslan Rezin' => 'ruslan@novasama.io'}
  s.source       = { :git => 'https://github.com/novasamatech/metadata-shortener-ios',  :tag => "#{s.version}"}

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.vendored_frameworks = 'bindings/xcframework/metadata_shortener.xcframework'
  s.source_files = 'Sources/**/*.swift'

end
