#
# Be sure to run `pod lib lint SmartMultipeer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'SmartMultipeer'
    s.version          = '0.1'
    s.summary          = 'Multipeer Connectivity for iOS Devices with Acknowlegement'
    s.swift_version    = '4.0'
    s.platform     = :ios, '11.0'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = 'Smart Multipeer Connectivity designed with acknowledgment facility that includes the time of delivery with the id of data sent. You can set primary id of your model which you want to sync'
    
    s.homepage         = 'https://github.com/ajsagar92/SmartMultipeer'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'ajay.sagar' => 'ajay.sagar92@gmail.com' }
    s.source           = { :git => 'https://github.com/ajsagar92/SmartMultipeer.git', :tag => '0.1' }
    
    s.ios.deployment_target = '11.0'
    
    s.source_files = 'SmartMultipeer/**/*.{swift}'
    
    s.dependency 'RealmSwift'
end
