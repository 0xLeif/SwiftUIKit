//
//  Map.swift
//  SwiftUIKit
//
//  Created by Oskar on 12/04/2020.
//

import Foundation
import MapKit

public class Map: MKMapView {
  
  fileprivate var initialCoordinates: CLLocationCoordinate2D
  
  fileprivate lazy var onFinishLoadingHandler: ((MKMapView) -> ())? = nil
  
  fileprivate lazy var onRegionChangeHandler: ((MKMapView) -> ())? = nil
  
  public init(lat latitude: Double,
              lon longitude: Double,
              annotations: (() -> [(latitude: CLLocationDegrees,
                                    longitude: CLLocationDegrees,
                                    title: String?,
                                    subtitle: String?)])? = nil) {
    
    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    initialCoordinates = coordinates
    
    super.init(frame: .zero)
    
    let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan())
    setRegion(region, animated: true)
    
    if let annotations = annotations {
      DispatchQueue.global().async { [weak self] in
        guard let self = self else { return }
        
        for (latitude, longitude, title, subtitle) in annotations() {
          let coordinate = CLLocationCoordinate2D(latitude: latitude,
                                                  longitude: longitude)
          let point = MKPointAnnotation()
          point.coordinate = coordinate
          point.title = title
          point.subtitle = subtitle
          
          DispatchQueue.main.async {
            self.addAnnotation(point)
          }
        }
      }
    }
    
    self.delegate = self
  }
  
  convenience init(region: MKCoordinateRegion,
                   annotations: (() -> [(latitude: CLLocationDegrees,
                   longitude: CLLocationDegrees,
                   title: String?,
                   subtitle: String?)])? = nil) {
    self.init(lat: region.center.latitude,
              lon: region.center.longitude,
              annotations: annotations)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Accessing Map Properties
extension Map {
  @discardableResult
  public func type(_ type: MKMapType) -> Self {
    mapType = type
    
    return self
  }
  
  @discardableResult
  public func zoomEnabled(_ value: Bool = true) -> Self {
    isZoomEnabled = value
    
    return self
  }
  
  @discardableResult
  public func scrollEnabled(_ value: Bool = true) -> Self {
    isScrollEnabled = value
    
    return self
  }
  
  @discardableResult
  public func pitchEnabled(_ value: Bool = true) -> Self {
    isPitchEnabled = value
    
    return self
  }
  
  @discardableResult
  public func rotateEnabled(_ value: Bool = true) -> Self {
    isRotateEnabled = value
    
    return self
  }
  
  /// Note: If delegate isn't its own class, modifiers with prefix `on...` will do nothing.
  @discardableResult
  public func delegate(_ delegate: MKMapViewDelegate?) -> Self {
    self.delegate = delegate ?? self
    
    return self
  }
}

// MARK: - Manipulating the Visible Portion of the Map
extension Map {
  @discardableResult
  public func zoom(_ multiplier: Double) -> Self {
    let _center = initialCoordinates
    let _span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / multiplier / 10,
                                longitudeDelta: region.span.longitudeDelta / multiplier / 10)
    let _region = MKCoordinateRegion(center: _center, span: _span)
    
    super.setRegion(_region, animated: false)
    return self
  }
  
  @discardableResult
  public func visibleRect(_ rect: MKMapRect,
                          animate: Bool = true,
                          edgePadding: UIEdgeInsets? = nil
                          ) -> Self {
    if let padding = edgePadding {
      super.setVisibleMapRect(rect, edgePadding: padding, animated: animate)
    } else {
      super.setVisibleMapRect(rect, animated: animate)
    }
    
    return self
  }
  
  @discardableResult
  public func move(to region: MKCoordinateRegion, animate: Bool = true) -> Self {
    var _region = region
    _region.span = self.region.span
    super.setRegion(_region, animated: animate)
    
    return self
  }
  
  @discardableResult
  public func center(_ center: CLLocationCoordinate2D, animated: Bool = true) -> Self {
    super.setCenter(center, animated: animated)
    
    return self
  }
  
  @discardableResult
  public func showAnnotations(_ annotations: [MKAnnotation], animated: Bool = true) -> Self {
    super.showAnnotations(annotations, animated: animated)
    
    return self
  }
  
  @discardableResult
  public func showAnnotations(_ annotations: MKAnnotation..., animated: Bool = true) -> Self {
    super.showAnnotations(annotations, animated: animated)
    
    return self
  }
}

// MARK: - Constraining the Map View

@available(iOS 13.0, *)
extension Map {
  @discardableResult
  public func cameraBoundary(_ boundary: MKMapView.CameraBoundary?, animated: Bool = true) -> Self {
    super.setCameraBoundary(boundary, animated: animated)
    
    return self
  }
  
  @discardableResult
  public func setCameraZoomRange(_ cameraZoomRange: MKMapView.CameraZoomRange?, animated: Bool) -> Self {
    super.setCameraZoomRange(cameraZoomRange, animated: animated)
    
    return self
  }
}

// MARK: - Configuring the Map's Appearance
extension Map {
  @discardableResult
  public func camera(_ camera: MKMapCamera, animated: Bool = true) -> Self {
    super.setCamera(camera, animated: animated)
    
    return self
  }
  
  @discardableResult
  public func showBuildings(_ bool: Bool? = nil) -> Self {
    showsBuildings = bool ?? !showsBuildings
    
    return self
  }
}

@available(iOS 13.0, *)
extension Map {
  @discardableResult
  public func showCompass(_ bool: Bool? = nil) -> Self {
    showsCompass = bool ?? !showsCompass
    
    return self
  }
  
  @discardableResult
  public func showScale(_ bool: Bool? = nil) -> Self {
    showsScale = bool ?? !showsScale
    
    return self
  }
  
  @discardableResult
  public func showTraffic(_ bool: Bool? = nil) -> Self {
    showsTraffic = bool ?? !showsTraffic
    
    return self
  }
  
  @discardableResult
  public func pointOfInterestFilter(_ filter: MKPointOfInterestFilter?) -> Self {
    pointOfInterestFilter = filter
    
    return self
  }
}

// MARK: - Displaying the User's Location
extension Map {
  @discardableResult
  public func showUserLocation(_ bool: Bool? = nil) -> Self {
    showsUserLocation = bool ?? !showsUserLocation
    
    return self
  }
  
  @discardableResult
  public func userTrackingMode(_ mode: MKUserTrackingMode, animated: Bool = true) -> Self {
    setUserTrackingMode(mode, animated: animated)
    
    return self
  }
}

// MARK: - Delegate wrappers
// If delegate isn't its own class, methods below will not execute.
extension Map {
  @discardableResult
  public func onFinishLoading(_ handler: @escaping (MKMapView) -> ()) -> Self {
    guard delegate === self else { return self }
    onFinishLoadingHandler = handler
    
    return self
  }
  
  @discardableResult
  public func onRegionChange(_ handler: @escaping (MKMapView) -> ()) -> Self {
    guard delegate === self else { return self }
    onRegionChangeHandler = handler
    
    return self
  }
}

// MARK: - Delegation
extension Map: MKMapViewDelegate {
  public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    onFinishLoadingHandler?(mapView)
  }
  
  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    onRegionChangeHandler?(mapView)
  }
}
