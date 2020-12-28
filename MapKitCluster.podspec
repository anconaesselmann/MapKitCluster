Pod::Spec.new do |s|
  s.name             = 'MapKitCluster'
  s.version          = '0.1.1'
  s.summary          = 'Efficient and customizable clustering for MKMapView'
  s.description      = <<-DESC
Efficient and customizable clustering for MKMapView.
                       DESC
  s.homepage         = 'https://github.com/anconaesselmann/MapKitCluster'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anconaesselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/MapKitCluster.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'MapKitCluster/Classes/**/*'
  s.swift_version = '5.0'
  s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SwiftQuadTree', '0.1.0'
end
