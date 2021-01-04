Pod::Spec.new do |s|

  s.name         				= "WWAirTableAPI"
  s.version      				= "0.0.2"
  s.summary      				= "WWAirTableAPI is sample API for AirTable. (簡易型基本的)"
  s.homepage     				= "https://github.com/William-Weng/WWAirTableAPI"
  s.license      				= { :type => "MIT", :file => "LICENSE" }
  s.author              = { "翁禹斌(William.Weng)" => "linuxice0609@gmail.com" }
  s.platform            = :ios, "11.0"
  s.ios.vendored_frameworks 	= "WWAirTableAPI.framework"
  s.source 						  = { :git => "https://github.com/William-Weng/WWAirTableAPI.git", :tag => "#{s.version}" }
  s.frameworks 					= 'UIKit'
  
end