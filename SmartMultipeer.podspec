#
# Be sure to run `pod lib lint SmartMultipeer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartMultipeer'
  s.version          = '0.1.0'
  s.summary          = 'Multipeer Connectivity for iOS Devices with Acknowlegement'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Smart Multipeer Connectivity designed with acknowledgment facility that includes the time of delivery with the id of data sent. You can set primary id of your model which you want to sync'

  s.homepage         = 'https://github.com/a.sagar@wizsoft.pk/SmartMultipeer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ajay.sagar' => 'ajay.sagar92@gmail.com' }
  s.source           = { :git => 'https://github.com/a.sagar@wizsoft.pk/SmartMultipeer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SmartMultipeer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SmartMultipeer' => ['SmartMultipeer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
