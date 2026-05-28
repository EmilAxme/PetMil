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

protocol LocationServiceProtocol: AnyObject {
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D
}

final class LocationService: NSObject, LocationServiceProtocol {

    private let manager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
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

    func resumeLocation(with result: Result<CLLocationCoordinate2D, Error>) {
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
        guard let coordinate = locations.last?.coordinate else {
            resumeLocation(with: .failure(LocationError.unavailable))
            return
        }
        resumeLocation(with: .success(coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeLocation(with: .failure(error))
    }
}
