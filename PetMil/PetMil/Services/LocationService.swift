//
//  LocationService.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import CoreLocation

enum LocationError: Error {
    case permissionDenied
    case servicesDisabled
    case unavailable
}

struct GeoCoordinate {
    let latitude: Double
    let longitude: Double
}

protocol LocationServiceProtocol: AnyObject {
    func requestCurrentLocation() async throws -> GeoCoordinate
}

final class LocationService: NSObject, LocationServiceProtocol {

    private let manager: CLLocationManager
    private var locationContinuation: CheckedContinuation<GeoCoordinate, Error>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() async throws -> GeoCoordinate {
        let status = await currentAuthorizationStatus()

        switch status {
        case .notDetermined, .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            throw LocationError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
}

private extension LocationService {
    func currentAuthorizationStatus() async -> CLAuthorizationStatus {
        let status = manager.authorizationStatus
        guard status == .notDetermined else { return status }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func resumeLocation(with result: Result<GeoCoordinate, Error>) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil
        continuation.resume(with: result)
    }

    func resumeAuthorization(with status: CLAuthorizationStatus) {
        guard let continuation = authorizationContinuation else { return }
        authorizationContinuation = nil
        continuation.resume(returning: status)
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        guard status != .notDetermined else { return }
        resumeAuthorization(with: status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            resumeLocation(with: .failure(LocationError.unavailable))
            return
        }
        let coordinate = GeoCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        resumeLocation(with: .success(coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeLocation(with: .failure(error))
    }
}
