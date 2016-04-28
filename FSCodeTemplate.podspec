#
# Be sure to run `pod lib lint FSCodeTemplate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FSCodeTemplate"
  s.version          = "0.1.2"
  s.summary          = "My own library to be used in every new project."
  s.homepage         = "https://github.com/bungferdly/FSCodeTemplate"
  s.license          = 'MIT'
  s.author           = { "Ferdly Sethio" => "bungferdly@gmail.com" }
  s.source           = { :git => "https://github.com/bungferdly/FSCodeTemplate.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.default_subspec  = 'Root'

  s.subspec 'Root' do |sp|
    sp.source_files  = 'Pod/**/*.{h,m}'
    sp.resources     = 'Pod/Resources/**/*'
  
    sp.dependency 'AFNetworking', '2.6.2'
    sp.dependency 'SVProgressHUD'
    sp.dependency 'JSONModel'
    sp.dependency 'NSURL+QueryDictionary'
    sp.dependency 'FXKeychain'
    sp.dependency 'TMCache'
    sp.dependency 'UIAlertController+Blocks'
    sp.dependency 'UIAlertView+Blocks'
    sp.dependency 'UIActionSheet+Blocks'
    sp.dependency 'SDWebImage'
    sp.dependency 'DTCoreText'
  end

  s.subspec 'Notification' do |sp|
    sp.source_files = 'PodNotification/*.{h,m}'
    sp.xcconfig     = {"GCC_PREPROCESSOR_DEFINITIONS" => "FS_SUBSPEC_NOTIFICATION"}
  end

end
