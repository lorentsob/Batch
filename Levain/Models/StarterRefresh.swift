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
        self.starter = starter
    }
}

