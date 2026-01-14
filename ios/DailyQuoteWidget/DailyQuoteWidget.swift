import WidgetKit
import SwiftUI

struct DailyQuoteWidget: Widget {
    let kind: String = "DailyQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyQuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Shows today's inspirational quote")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quoteText: "Loading...", quoteAuthor: "Author", isDarkMode: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.quote.app")
        
        // home_widget package stores data with "home_widget." prefix
        let quoteText = userDefaults?.string(forKey: "home_widget.quote_text") 
            ?? userDefaults?.string(forKey: "quote_text") 
            ?? "Loading quote..."
        let quoteAuthor = userDefaults?.string(forKey: "home_widget.quote_author")
            ?? userDefaults?.string(forKey: "quote_author")
            ?? "Author"
        let isDarkMode = userDefaults?.bool(forKey: "home_widget.is_dark_mode") ?? true
        
        let entry = SimpleEntry(
            date: Date(),
            quoteText: quoteText,
            quoteAuthor: quoteAuthor,
            isDarkMode: isDarkMode
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.quote.app")
        
        // home_widget package stores data with "home_widget." prefix
        // Try both formats for compatibility
        let quoteText = userDefaults?.string(forKey: "home_widget.quote_text")
            ?? userDefaults?.string(forKey: "quote_text")
            ?? "Loading quote..."
        let quoteAuthor = userDefaults?.string(forKey: "home_widget.quote_author")
            ?? userDefaults?.string(forKey: "quote_author")
            ?? "Author"
        let isDarkMode = userDefaults?.bool(forKey: "home_widget.is_dark_mode") ?? true
        
        let entry = SimpleEntry(
            date: Date(),
            quoteText: quoteText,
            quoteAuthor: quoteAuthor,
            isDarkMode: isDarkMode
        )
        
        // Create multiple entries throughout the day to ensure widget stays updated
        // Update at midnight, 6 AM, 12 PM, and 6 PM
        let calendar = Calendar.current
        let now = Date()
        var entries: [SimpleEntry] = [entry]
        
        // Add entries for the rest of today
        let today = calendar.startOfDay(for: now)
        let sixAM = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today)!
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let sixPM = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!
        let midnight = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Add future entries if they haven't passed yet
        if now < sixAM {
            entries.append(SimpleEntry(date: sixAM, quoteText: quoteText, quoteAuthor: quoteAuthor, isDarkMode: isDarkMode))
        }
        if now < noon {
            entries.append(SimpleEntry(date: noon, quoteText: quoteText, quoteAuthor: quoteAuthor, isDarkMode: isDarkMode))
        }
        if now < sixPM {
            entries.append(SimpleEntry(date: sixPM, quoteText: quoteText, quoteAuthor: quoteAuthor, isDarkMode: isDarkMode))
        }
        
        // Always add midnight entry for next day
        entries.append(SimpleEntry(date: midnight, quoteText: quoteText, quoteAuthor: quoteAuthor, isDarkMode: isDarkMode))
        
        // Refresh policy: reload at midnight
        let timeline = Timeline(entries: entries, policy: .after(midnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quoteText: String
    let quoteAuthor: String
    let isDarkMode: Bool
}

struct DailyQuoteWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let isDark = entry.isDarkMode
        let gradientColors: [Color]
        let textColor: Color
        let authorColor: Color
        let iconColor: Color
        
        // Adapt sizes based on widget family
        let quoteFontSize: CGFloat = family == .systemMedium ? 16 : 14
        let authorFontSize: CGFloat = family == .systemMedium ? 14 : 12
        let iconSize: CGFloat = family == .systemMedium ? 14 : 12
        let padding: CGFloat = family == .systemMedium ? 18 : 14
        let cornerRadius: CGFloat = family == .systemMedium ? 18 : 16
        let maxLines = family == .systemMedium ? 5 : 4
        
        if isDark {
            // Dark theme: Dark blue gradient with high contrast text
            gradientColors = [
                Color(red: 0.10, green: 0.10, blue: 0.18), // #1A1A2E
                Color(red: 0.09, green: 0.13, blue: 0.24)  // #16213E
            ]
            textColor = .white // Full white for maximum contrast
            authorColor = .white // Full white for author too
            iconColor = Color.white.opacity(0.8)
        } else {
            // Light theme: Light background with subtle blue gradient
            gradientColors = [
                Color(red: 0.98, green: 0.98, blue: 0.99), // Very light gray-blue (#FAFAFC)
                Color(red: 0.95, green: 0.96, blue: 0.98)  // Slightly darker light gray-blue (#F3F4F8)
            ]
            // Use dark blue-gray instead of pure black for better visual appeal
            textColor = Color(red: 0.15, green: 0.20, blue: 0.30) // Dark blue-gray (#26334D)
            authorColor = Color(red: 0.15, green: 0.20, blue: 0.30) // Same color
            iconColor = Color(red: 0.15, green: 0.20, blue: 0.30).opacity(0.7)
        }
        
        return ZStack {
            // Gradient background matching app's theme
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 0) {
                // Decorative quote icon at top with better styling
                HStack {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 24, height: 24)
                        Image(systemName: "quote.opening")
                            .font(.system(size: iconSize, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    Spacer()
                }
                .padding(.bottom, family == .systemMedium ? 12 : 8)
                
                // Quote Text with improved typography and better readability
                Text(entry.quoteText)
                    .font(.system(size: quoteFontSize, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(maxLines)
                    .lineSpacing(family == .systemMedium ? 5 : 4)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .tracking(0.2)
                    .shadow(color: isDark ? Color.black.opacity(0.3) : Color.white.opacity(0.5), radius: 1, x: 0, y: 0.5)
                
                Spacer(minLength: family == .systemMedium ? 8 : 4)
                
                // Author with decorative dash and better styling
                HStack(spacing: 6) {
                    Text("—")
                        .font(.system(size: authorFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(authorColor)
                    Text(entry.quoteAuthor)
                        .font(.system(size: authorFontSize, weight: .semibold, design: .rounded))
                        .foregroundColor(authorColor)
                }
                .padding(.top, family == .systemMedium ? 6 : 4)
                .shadow(color: isDark ? Color.black.opacity(0.3) : Color.white.opacity(0.5), radius: 1, x: 0, y: 0.5)
            }
            .padding(padding)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isDark 
                                ? Color(red: 0.29, green: 0.56, blue: 0.89).opacity(0.4)
                                : Color(red: 0.29, green: 0.56, blue: 0.89).opacity(0.25),
                            isDark 
                                ? Color(red: 0.29, green: 0.56, blue: 0.89).opacity(0.2)
                                : Color(red: 0.29, green: 0.56, blue: 0.89).opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isDark 
                ? Color.black.opacity(0.4) 
                : Color.black.opacity(0.12),
            radius: family == .systemMedium ? 12 : 8,
            x: 0,
            y: family == .systemMedium ? 4 : 2
        )
        .widgetURL(URL(string: "quoteapp://daily"))
    }
}

@main
struct DailyQuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyQuoteWidget()
    }
}

