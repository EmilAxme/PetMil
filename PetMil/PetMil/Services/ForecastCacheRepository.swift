//
//  ForecastCacheRepository.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import CoreData

struct CachedWeather: Codable {
    let forecast: Forecast
    let currentWeather: CurrentWeather?
    let cityName: String
}

struct CachedWeatherEntry {
    let payload: CachedWeather
    let fetchedAt: Date
}

protocol ForecastCacheRepositoryProtocol: AnyObject {
    func loadCached(for cityKey: String) -> CachedWeatherEntry?
    func saveCache(_ payload: CachedWeather, for cityKey: String, at date: Date)
}

final class ForecastCacheRepository: ForecastCacheRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func loadCached(for cityKey: String) -> CachedWeatherEntry? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDForecastSnapshot")
        request.predicate = NSPredicate(format: "cityKey == %@", cityKey)
        request.fetchLimit = 1

        guard let object = try? context.fetch(request).first,
              let data = object.value(forKey: "payload") as? Data,
              let fetchedAt = object.value(forKey: "fetchedAt") as? Date,
              let payload = try? JSONDecoder().decode(CachedWeather.self, from: data)
        else { return nil }

        return CachedWeatherEntry(payload: payload, fetchedAt: fetchedAt)
    }

    func saveCache(_ payload: CachedWeather, for cityKey: String, at date: Date) {
        guard let data = try? JSONEncoder().encode(payload) else { return }

        let request = NSFetchRequest<NSManagedObject>(entityName: "CDForecastSnapshot")
        request.predicate = NSPredicate(format: "cityKey == %@", cityKey)
        request.fetchLimit = 1

        let object: NSManagedObject
        if let existing = try? context.fetch(request).first {
            object = existing
        } else {
            guard let entity = NSEntityDescription.entity(forEntityName: "CDForecastSnapshot", in: context) else { return }
            object = NSManagedObject(entity: entity, insertInto: context)
        }

        object.setValue(cityKey, forKey: "cityKey")
        object.setValue(date, forKey: "fetchedAt")
        object.setValue(data, forKey: "payload")

        do {
            try context.save()
        } catch {
            print("Cache save error:", error.localizedDescription)
        }
    }
}
