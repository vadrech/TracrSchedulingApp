# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'SchedulingApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SchedulingApp

  pod 'GoogleSignIn'
  pod 'GoogleAPIClientForREST/Classroom'

  target 'SchedulingAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SchedulingAppUITests' do
    # Pods for testing

  end
# workspace 'SchedulingApp'

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end