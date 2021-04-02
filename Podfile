# Uncomment the next line to define a global platform for your project

target 'MVVM-Pratice' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MVVM-Pratice
  pod 'RxSwift', '6.1.0'
  pod 'RxCocoa', '6.1.0'
  pod 'RxDataSources'
  pod 'MJRefresh'
  pod 'SDWebImage', '~> 5.0'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
      end
    end
  end
  
  target 'MVVM-PraticeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MVVM-PraticeUITests' do
    # Pods for testing
  end

end
