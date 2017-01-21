Pod::Spec.new do |s|
  s.name             = 'MpegUrlKit'
  s.version          = '0.1.0-a'
  s.summary          = 'MpegUrlKit is a serializer/deserializer of m3u (m3u8) format used in HLS.'
  s.homepage         = 'https://github.com/soranoba/MpegUrlKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'soranoba' => 'soranoba@gmail.com' }
  s.source           = { :git => 'https://github.com/soranoba/MpegUrlKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files         = 'MpegUrlKit/Classes/**/*.{m,h}'
  s.private_header_files = 'MpegUrlKit/Classes/Private/*.h'
end
