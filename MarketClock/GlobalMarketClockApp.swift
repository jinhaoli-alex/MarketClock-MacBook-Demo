import SwiftUI

/// Defines the static configuration for a financial market.
struct MarketConfig: Identifiable {
    let id = UUID()
    let name: String
    let flag: String // Emoji flag
    let regionName: String
    let timeZoneID: String
    let accentColor: Color
    
    // Trading hours in local 24-hour format
    let openHour: Int
    let openMinute: Int
    let closeHour: Int
    let closeMinute: Int
    
    // Helper to get the Foundation TimeZone
    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneID) ?? TimeZone.current
    }
}

/// Represents the dynamic state of a market (time, status, positions).
struct MarketState {
    let config: MarketConfig
    let localTimeString: String
    let statusText: String
    let isOpen: Bool
    
    // Values from 0.0 to 1.0 representing position on the 24h bar
    let currentDayProgress: Double
    let openProgress: Double
    let closeProgress: Double
    
    // For tooltip details
    let openTimeDisplay: String
    let closeTimeDisplay: String
}
