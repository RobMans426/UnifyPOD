#platform :ios, "10.0.2"

use_frameworks!
target 'UnifyPOD' do
    pod 'SwiftyJSON'
    pod 'Google/Analytics'
    pod 'Alamofire', '~> 4.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
