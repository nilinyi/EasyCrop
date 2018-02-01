#
# Be sure to run `pod lib lint EasyCrop.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyCrop'
  s.version          = '1.0.0'
  s.summary          = 'A lightweight image cropping UI for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Implementing a UI for cropping image could be a headache in iOS. Well, you might find a library which could work but it sometimes introduces tons of unnecessary features, for example, image filter, or, it might have a lot of unnecessary UI that makes it impossible to customize. However, EasyCrop is just a very very simple library. It only provides a subclass of UIView which helps you crop an image. It's just that simple.
                       DESC

  s.homepage         = 'https://github.com/nilinyi/EasyCrop'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Linyi (Leo) Ni' => 'nilinyi@gmail.com' }
  s.source           = { :git => 'https://github.com/nilinyi/EasyCrop.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.linkedin.com/in/linyi-ni/'

  s.ios.deployment_target = '9.0'

  s.source_files = 'EasyCrop/Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'EasyCrop' => ['EasyCrop/Assets/*.png']
  # }

#  s.public_header_files = 'EasyCrop/Classes/Public/EasyCrop.h'
#  s.private_header_files = 'EasyCrop/Classes/**/*.h'

  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
