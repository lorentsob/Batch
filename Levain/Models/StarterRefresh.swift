import Foundation
import SwiftData

@Model
final class StarterRefresh {
    @Attribute(.unique) var id: UUID
    var dateTime: Date
    var flourWeight: Double
    var waterWeight: Double
    var starterWeightUsed: Double
    var ratioText: String
    var putInFridgeAt: Date?
    var notes: String
    var ambientTemp: Double
    var photoURI: String
    var floursPayload: Data?
    var starter: Starter?

    init(
        id: UUID = UUID(),
        dateTime: Date = .now,
        flourWeight: Double,
        waterWeight: Double,
        starterWeightUsed: Double,
        ratioText: String,
        putInFridgeAt: Date? = nil,
        notes: String = "",
        ambientTemp: Double = 0,
        photoURI: String = "",
        flours: [FlourSelection] = [],
        starter: Starter? = nil
    ) {
        self.id = id
        self.dateTime = dateTime
        self.flourWeight = flourWeight
        self.waterWeight = waterWeight
        self.starterWeightUsed = starterWeightUsed
        self.ratioText = ratioText
        self.putInFridgeAt = putInFridgeAt
        self.notes = notes
        self.ambientTemp = ambientTemp
        self.photoURI = photoURI
        self.floursPayload = Self.encode(flours: flours)
        self.starter = starter
    }

    var selectedFlours: [FlourSelection] {
        get { Self.decode(flours: floursPayload) }
        set { floursPayload = Self.encode(flours: newValue) }
    }

    private static func encode(flours: [FlourSelection]) -> Data {
        guard let data = try? JSONEncoder().encode(flours) else { return Data() }
        return data
    }

    private static func decode(flours payload: Data?) -> [FlourSelection] {
        guard let payload = payload, !payload.isEmpty,
              let flours = try? JSONDecoder().decode([FlourSelection].self, from: payload) else {
            return []
        }
        return flours
    }
}

