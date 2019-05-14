platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

# This enables the cutting-edge staging builds of AudioKit, comment this line to stick to stable releases
source 'https://github.com/AudioKit/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

def available_pods
    pod 'AppCenter'
    pod 'AudioKit', '= 4.7.2.b1'
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
    pod 'AudioKit', '= 4.7.2.b1'
end


# Override Swift version for out of date pods
post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED'] = 'YES'
      end
      if ['Disk'].include? target.name
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.0'
          end
      end
  end
end
