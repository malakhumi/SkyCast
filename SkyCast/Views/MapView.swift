//  MapView.swift
//  SkyCast

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let latitude: Double
        let longitude: Double
        let title: String
        let isNight: Bool

        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = false
            mapView.isPitchEnabled = false
            mapView.isRotateEnabled = false
            mapView.isUserInteractionEnabled = false
            return mapView
        }

        func updateUIView(_ mapView: MKMapView, context: Context) {
            mapView.overrideUserInterfaceStyle = isNight ? .dark : .light

            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 40_000,
                    longitudinalMeters: 40_000
                ),
                animated: false
            )

            mapView.removeAnnotations(mapView.annotations)

            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            pin.title = title
            mapView.addAnnotation(pin)
        }
    
}
