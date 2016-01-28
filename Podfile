# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'restkit-test' do
  pod 'RestKit', '~> 0.25.0'
  pod 'PromiseKit', '~> 3.0'
  pod 'Pluralize.swift', :git => 'https://github.com/sammy-SC/Pluralize.swift.git', :branch => 'master'

  # using core 'Reachability' pod causes app to get rejected for accessing private frameworks. See: https://github.com/tonymillion/Reachability/issues/95
  pod 'TMReachability', :git => 'https://github.com/albertbori/Reachability', :commit => 'e34782b386307e386348b481c02c176d58ba45e6'
end

