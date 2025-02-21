Pod::Spec.new do |spec|
  spec.name         = 'CustomCameraPackage'
  spec.version      = '1.0.1'
spec.summary        = 'A custom camera package for iOS.'
spec.description    = 'This package provides a custom camera implementation for iOS apps.'
  spec.homepage     = 'https://github.com/xtracapindia-dhananjay/CustomCameraPackage'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Dhananjay' => 'xtracapindia.dhananjay@gmail.com' }
  spec.source       = { :git => 'https://github.com/xtracapindia-dhananjay/CustomCameraPackage.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '15.0'
  spec.swift_version = '5.0'
  spec.source_files = 'Sources/**/*.{h,m,swift}'
end
