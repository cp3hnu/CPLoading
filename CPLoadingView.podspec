Pod::Spec.new do |s|
  s.name             = "CPLoadingView"
  s.version          = "1.1.0"
  s.summary          = "CPLoading shows loading process and completes successfully or unsuccessfully in the animation."
  s.homepage         = "https://github.com/cp3hnu/CPLoading"
  s.license          = 'MIT'
  s.author           = { "Wei Zhao" => "cp3hnu@gmail.com" }
  s.source           = { :git => "https://github.com/cp3hnu/CPLoading.git", :tag => s.version }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Classes/*.swift'
end
