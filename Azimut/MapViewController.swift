//
//  ViewController.swift
//  Azimut
//
//  Created by Marcel Mierzejewski on 13/09/2020.
//  Copyright © 2020 Marcel Mierzejewski. All rights reserved.
//

import UIKit
import MapKit
import Combine

final class MapViewController: UIViewController, MKMapViewDelegate {
    
    private let locationManager = LocationManager()
    private let mapView = MKMapView()
    
    private var visitedLocations = [CLLocation]()
    
    private enum ViewingMode: Int, CaseIterable {
        case centerMapOnUser, free
    }
    private var viewingMode: ViewingMode = .centerMapOnUser
    
    private var locationCancellable: AnyCancellable?
    
    private var locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.imageView?.tintColor = .white
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private var startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        button.imageView?.tintColor = .white
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private var speedStackView: UIStackView = {
        let speedLabel = UILabel()
        speedLabel.text = "Average speed"
        speedLabel.textAlignment = .center
        speedLabel.numberOfLines = 2
        speedLabel.textColor = .white
        //bolt.fill
        
        let valueLabel = UILabel()
        valueLabel.text = "5.21"
        valueLabel.textAlignment = .center
        valueLabel.textColor = .white
        valueLabel.font = .boldSystemFont(ofSize: 30)
        valueLabel.tag = "speed".hashValue
        
        let stackView = UIStackView(arrangedSubviews: [speedLabel, valueLabel])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()
    
    private var timeStackView: UIStackView = {
        let timeLabel = UILabel()
        timeLabel.text = "Time:"
        timeLabel.textAlignment = .center
        timeLabel.numberOfLines = 2
        timeLabel.textColor = .white
        //clock.fill
        
        let valueLabel = UILabel()
        valueLabel.text = "3:40"
        valueLabel.textAlignment = .center
        valueLabel.textColor = .white
        valueLabel.font = .boldSystemFont(ofSize: 30)
        valueLabel.tag = "time".hashValue
        
        let stackView = UIStackView(arrangedSubviews: [timeLabel, valueLabel])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()
    
    private var distanceStackView: UIStackView = {
        let speedLabel = UILabel()
        speedLabel.text = "Distance"
        speedLabel.textAlignment = .center
        speedLabel.numberOfLines = 2
        speedLabel.textColor = .white
        //flag.fill
        
        //flame.fill
        //waveform.path.ecg
        
        let valueLabel = UILabel()
        valueLabel.text = "400m"
        valueLabel.textAlignment = .center
        valueLabel.textColor = .white
        valueLabel.font = .boldSystemFont(ofSize: 30)
        valueLabel.tag = "distance".hashValue
        
        let stackView = UIStackView(arrangedSubviews: [speedLabel, valueLabel])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()
    
    let startDate = Date()
    var traveledDistance: Double = 0
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.showsLargeContentViewer = true
        mapView.isScrollEnabled = false
        mapView.showsTraffic = false
        
        mapView.delegate = self
        
        locationCancellable = locationManager.$userLocation.dropFirst().sink { location in
            self.visitedLocations.append(location)
            
            if self.startLocation == nil {
                self.startLocation = self.visitedLocations.first
            } else {
                let lastLocation = self.visitedLocations.last
                let distance = self.startLocation!.distance(from: lastLocation!)
                self.startLocation = lastLocation
                self.traveledDistance += distance
            }
            
            (self.speedStackView.arrangedSubviews.first(where: { $0.tag == "speed".hashValue })! as! UILabel).text = "\(location.speed)"
            (self.timeStackView.arrangedSubviews.first(where: { $0.tag == "time".hashValue })! as! UILabel).text = String(format: "%.0fs", Date().timeIntervalSince(self.startDate))
            (self.distanceStackView.arrangedSubviews.first(where: { $0.tag == "distance".hashValue })! as! UILabel).text = "\(Int(self.traveledDistance.rounded()))m"

            var visitedLocationsCoords = self.visitedLocations.map{ $0.coordinate }
            let polyline = MKPolyline(coordinates: &visitedLocationsCoords, count: self.visitedLocations.count)
            
            self.mapView.addOverlay(polyline)
            switch self.viewingMode {
            case .centerMapOnUser:
                
                self.mapView.centerToLocation(location)
            case .free:
                
                break
            }
        }
        
        view.addFitSubview(mapView)
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationButton)
        locationButton.addTarget(self, action: #selector(locationButtonAction), for: .touchUpInside)
        NSLayoutConstraint.activate([
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [speedStackView, timeStackView, distanceStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        
        let containerView = UIView()
        containerView.backgroundColor = .black
        containerView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.addFitSubview(stackView, toMargins: true)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKPolyline else { return MKOverlayRenderer() }
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3
        
        return renderer
    }
    
    @objc func locationButtonAction() {
        var nextViewingMode = self.viewingMode.rawValue + 1
        if nextViewingMode >= ViewingMode.allCases.count { nextViewingMode = 0 }
        
        viewingMode = ViewingMode(rawValue: nextViewingMode)!
        print("Viewing mode is now:", viewingMode)
        
        mapView.isScrollEnabled = viewingMode != .centerMapOnUser
        
        switch viewingMode {
        case .centerMapOnUser:
            mapView.centerToLocation(locationManager.userLocation)
            locationButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            
        case .free:
            locationButton.setImage(UIImage(systemName: "map.fill"), for: .normal)
        }
    }
    
    @objc func startButtonAction() {
        startButton.setImage(UIImage(systemName: "square.fill"), for: .normal)
    }
}



// MARK:- Move those below

extension UIView {
    func addFitSubview(_ subview: UIView, toMargins: Bool = false) {
        let layoutGuide = toMargins ? self.layoutMarginsGuide : self.safeAreaLayoutGuide
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            subview.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            subview.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
        ])
    }
}

private extension MKMapView {
    func centerToLocation( _ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
