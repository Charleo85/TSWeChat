source 'https://github.com/CocoaPods/Specs.git'

platform:ios,'8.0'
use_frameworks!
# ignore all warnings from all pods
inhibit_all_warnings!

def pods
    #Swift
    pod 'Alamofire', '~> 3.5.0'
    pod 'Kingfisher', '~> 2.6'
    pod 'ObjectMapper', '~> 1.4'
    pod 'SwiftyJSON', '~>2.4.0'
    pod 'Dollar'
    pod 'Cent'
    pod 'KeychainAccess', '~> 2.4'
    pod 'UIColor_Hex_Swift', '~> 2.0'
    pod 'RxSwift', '~> 2.6'
    pod 'RxCocoa', '~> 2.6'
    pod 'RxBlocking', '~> 2.6'
    pod 'XCGLogger', '~>3.6.0'
    pod 'SnapKit', '~> 0.22.0'
    pod 'BSImagePicker', '2.4.0'
    pod 'TSVoiceConverter', '0.1.2'
    pod 'SWXMLHash', '~> 2.5.1'

    #Objective-C
    pod 'YYText'
    pod 'SVProgressHUD'
    pod 'INTULocationManager'
end

target 'WuChat' do
    pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
