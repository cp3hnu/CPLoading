#
# Be sure to run `pod lib lint MyClass.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CPLoadingView"
  s.version          = "0.1.0"
  s.summary          = "CPLoading shows loading process and ends with success or failure status"
  s.homepage         = "https://github.com/cp3hnu/CPLoading"
  s.license          = 'MIT'
  s.author           = { "Wei Zhao" => "cp3hnu@gmail.com" }
  s.source           = { :git => "https://github.com/cp3hnu/CPLoading.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Src/*.swift'
end
