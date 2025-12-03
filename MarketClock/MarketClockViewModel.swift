import SwiftUI
import Combine

class MarketClockViewModel: ObservableObject {
    @Published var marketStates: [MarketState] = []
    
    // Timer to update the clock
    private var timer: AnyCancellable?
    
    // Define our markets
    private let markets: [MarketConfig] = [
        MarketConfig(
            name: "London (LSE)",
            flag: "🇬🇧",
            regionName: "London",
            timeZoneID: "Europe/London",
            accentColor: .blue,
            openHour: 8, openMinute: 0,   // 08:00
            closeHour: 16, closeMinute: 30 // 16:30
        ),
        MarketConfig(
            name: "New York (NYSE/NASDAQ)",
            flag: "🇺🇸",
            regionName: "New York",
            timeZoneID: "America/New_York",
            accentColor: .green,
            openHour: 9, openMinute: 30,  // 09:30
            closeHour: 16, closeMinute: 0 // 16:00
        ),
        MarketConfig(
            name: "Sydney (ASX)",
            flag: "🇦🇺",
            regionName: "Sydney",
            timeZoneID: "Australia/Sydney",
            accentColor: .orange,
            openHour: 10, openMinute: 0,  // 10:00
            closeHour: 16, closeMinute: 0 // 16:00
        )
    ]
    
    init() {
        updateTimes()
        // Update every second for smooth ticking
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimes()
            }
    }
    
    private func updateTimes() {
        let now = Date()
        var newStates: [MarketState] = []
        
        for market in markets {
            var calendar = Calendar.current
            calendar.timeZone = market.timeZone
            
            // 1. Get current components in local time
            let components = calendar.dateComponents([.hour, .minute, .second], from: now)
            let currentSeconds = Double(components.hour! * 3600 + components.minute! * 60 + components.second!)
            let totalSecondsInDay: Double = 86400
            
            // 2. Calculate Progress (0.0 - 1.0)
            let currentProgress = currentSeconds / totalSecondsInDay
            
            // 3. Calculate Open/Close progress
            let openSeconds = Double(market.openHour * 3600 + market.openMinute * 60)
            let closeSeconds = Double(market.closeHour * 3600 + market.closeMinute * 60)
            
            let openProg = openSeconds / totalSecondsInDay
            let closeProg = closeSeconds / totalSecondsInDay
            
            // 4. Determine Status
            let isOpen = currentSeconds >= openSeconds && currentSeconds < closeSeconds
            
            // 5. Format Strings
            let formatter = DateFormatter()
            formatter.timeZone = market.timeZone
            formatter.dateFormat = "HH:mm:ss"
            let timeString = formatter.string(from: now)
            
            // Helper for open/close label
            let openTimeStr = String(format: "%02d:%02d", market.openHour, market.openMinute)
            let closeTimeStr = String(format: "%02d:%02d", market.closeHour, market.closeMinute)
            
            let state = MarketState(
                config: market,
                localTimeString: timeString,
                statusText: isOpen ? "MARKET OPEN" : "MARKET CLOSED",
                isOpen: isOpen,
                currentDayProgress: currentProgress,
                openProgress: openProg,
                closeProgress: closeProg,
                openTimeDisplay: openTimeStr,
                closeTimeDisplay: closeTimeStr
            )
            newStates.append(state)
        }
        
        self.marketStates = newStates
    }
}
