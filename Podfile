
workspace 'MpegUrlKit.xcworkspace'
project   'MpegUrlKit.xcodeproj'

use_frameworks!
target :MpegUrlKitTests do
  inherit! :search_paths

  pod 'MpegUrlKit/Full', :path => '.'

  pod 'Quick',  '0.10.0'
  pod 'Nimble', '5.1.1'
  pod 'OCMock', '3.3.1'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
