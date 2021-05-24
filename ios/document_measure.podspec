#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint documentmeasure.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'document_measure'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Document Measure Plugin'
  s.description      = <<-DESC
A widget that allows you to measure distances in documents.
                       DESC
  s.homepage         = 'https://github.com/arconsis/measurements'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'arconsis IT-Solutions GmbH' => 'kontakt@arconsis.com' }
  s.source           = { :http => 'https://github.com/arconsis/measurements' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
