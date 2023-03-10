//
//  AGTHTTPModelManager.swift
//  AGT
//
//  Created by r.latypov on 12.12.2022.
//

import Foundation


final class AGTHTTPModelManager: NSObject {

    static let shared = AGTHTTPModelManager()

    let publisher = Publisher<[AGTHTTPModel]>()

    /// Not thread safe. Use only from main thread/queue
    private(set) var models = [AGTHTTPModel]() {
        didSet {
            notifySubscribers()
        }
    }

    /// Not thread safe. Use only from main thread/queue
    var filters = [Bool](repeating: true, count: HTTPModelShortType.allCases.count) {
        didSet {
            notifySubscribers()
        }
    }

    /// Not thread safe. Use only from main thread/queue
    var filteredModels: [AGTHTTPModel] {
        let filteredTypes = getCachedFilterTypes()
        return models.filter { filteredTypes.contains($0.shortType) }
    }

    /// Thread safe
    func add(_ obj: AGTHTTPModel) {
        DispatchQueue.main.async {
            self.models.insert(obj, at: 0)
        }
    }

    /// Not thread safe. Use only from main thread/queue
    func clear() {
        models.removeAll()
    }

    private func getCachedFilterTypes() -> [HTTPModelShortType] {
        return filters
            .enumerated()
            .compactMap { $1 ? HTTPModelShortType.allCases[$0] : nil }
    }

    private func notifySubscribers() {
        if publisher.hasSubscribers {
            publisher(filteredModels)
        }
    }

}
