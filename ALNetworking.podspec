Pod::Spec.new do |s|
    s.name             = 'ALNetworking'
    s.version          = '2.0.0'
    s.summary          = 'iOS Network layer framework.'
    
    s.description      = <<-DESC
    iOS Network layer framework.Basic on AFNetworking、YYCache.Also can depend on ReactiveObjc to support FRP form.
    DESC
    
    s.homepage         = 'https://git.linghit.io/ios_cocoapods/ALNetworking'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Arclin' => 'arcli325n@gmail.com' }
    s.source           = { :git => 'https://github.com/Arc-lin/ALNetworking.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '9.0'
    
    s.source_files = 'ALNetworking/Classes/**/*'
    
    s.subspec 'Core' do |ss|
        ss.dependency 'AFNetworking'
        ss.dependency 'YYCache'
        ss.source_files = 'ALNetworking/Classes/Core/**/*'
    end
    s.subspec 'RAC' do |ss|
        ss.prefix_header_contents = '#import <ReactiveObjC/ReactiveObjC.h>'
        ss.source_files = 'ALNetworking/Classes/Core/**/*'
        ss.dependency 'ReactiveObjC'
    end
    s.subspec 'RAC_MJ' do |ss|
        ss.prefix_header_contents = '#import <ReactiveObjC/ReactiveObjC.h>'
        ss.source_files = 'ALNetworking/Classes/Extensions/**/*'
        ss.dependency 'ALNetworking/RAC'
        ss.dependency 'ReactiveObjC'
        ss.dependency 'MJExtension'
    end
    
    s.subspec 'Recorder' do |ss|
        ss.source_files = 'ALNetworking/Classes/UI/**/*'
        ss.dependency 'ALNetworking/Core'
        ss.dependency 'Masonry'
    end
end
