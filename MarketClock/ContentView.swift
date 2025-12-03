import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketClockViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)
                Text("Global Market Clock")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(20)
            .background(.regularMaterial)
            
            // Market List
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(viewModel.marketStates, id: \.config.id) { state in
                        MarketRowView(state: state)
                    }
                }
                .padding(24)
            }
        }
        .frame(minWidth: 700, minHeight: 450)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Market Row View
struct MarketRowView: View {
    let state: MarketState
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Labels
            HStack {
                Text(state.config.flag)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(state.config.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(state.config.regionName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Live Status Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(state.isOpen ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(state.statusText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(state.isOpen ? Color.green : Color.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .strokeBorder(state.isOpen ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
                )
                
                // Digital Clock
                Text(state.localTimeString)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .frame(width: 100, alignment: .trailing)
            }
            
            // The Bar
            TimeBarView(state: state, isHovering: isHovering)
                .frame(height: 50)
                .onHover { hover in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hover
                    }
                }
                .overlay(alignment: .top) {
                    // Hover Tooltip
                    if isHovering {
                        TooltipView(state: state)
                            .offset(y: -45)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Time Bar View (Drawing Logic)
struct TimeBarView: View {
    let state: MarketState
    let isHovering: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 1. Background Track
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 12)
                
                // 2. Hour Ticks (0-24)
                ForEach(0...24, id: \.self) { hour in
                    let xPos = geo.size.width * (Double(hour) / 24.0)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: hour % 6 == 0 ? 12 : 6) // Taller ticks every 6h
                        .position(x: xPos, y: 6)
                    
                    if hour % 6 == 0 {
                        Text("\(hour)")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .position(x: xPos, y: 20)
                    }
                }
                
                // 3. Trading Session Highlight
                let sessionWidth = (state.closeProgress - state.openProgress) * geo.size.width
                let sessionX = state.openProgress * geo.size.width
                
                if sessionWidth > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    state.config.accentColor.opacity(0.6),
                                    state.config.accentColor.opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: sessionWidth, height: 12)
                        .offset(x: sessionX)
                        // Add glow if open
                        .shadow(color: state.isOpen ? state.config.accentColor.opacity(0.5) : .clear, radius: 4)
                }
                
                // 4. Current Time Tick
                let tickX = state.currentDayProgress * geo.size.width
                
                ZStack {
                    // The line
                    Rectangle()
                        .fill(state.isOpen ? Color.white : Color.gray)
                        .frame(width: 2, height: 24)
                    
                    // The head/indicator
                    Circle()
                        .fill(state.isOpen ? state.config.accentColor : Color.gray)
                        .frame(width: 10, height: 10)
                        .shadow(radius: 2)
                        .offset(y: -12)
                }
                .position(x: tickX, y: 6)
                .animation(.linear(duration: 1.0), value: state.currentDayProgress)
            }
            .padding(.vertical, 10) // Internal padding for labels
        }
    }
}

// MARK: - Tooltip View
struct TooltipView: View {
    let state: MarketState
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("Open")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(state.openTimeDisplay)
                    .font(.caption)
                    .bold()
            }
            
            Divider()
                .frame(height: 20)
            
            VStack(alignment: .leading) {
                Text("Close")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(state.closeTimeDisplay)
                    .font(.caption)
                    .bold()
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
