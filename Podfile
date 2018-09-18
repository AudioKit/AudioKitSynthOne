platform :ios, '9.0'
use_frameworks!

# This enables the cutting-edge staging builds of AudioKit, comment this line to stick to stable releases
source 'https://github.com/AudioKit/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

def available_pods
    pod 'AudioKit', '= 4.4.0.b1'
    pod 'Disk', '~> 0.3.2'
    pod 'Audiobus'
    pod 'ChimpKit'
    pod 'OneSignal', '>= 2.6.2', '< 3.0'
end

target 'AudioKitSynthOne' do
    available_pods
end

target 'OneSignalNotificationServiceExtension' do
    pod 'OneSignal', '>= 2.6.2', '< 3.0'
    pod 'AudioKit', '= 4.4.0.b1'
end
