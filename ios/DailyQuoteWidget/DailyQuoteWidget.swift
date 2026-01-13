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
        SimpleEntry(date: Date(), quoteText: "Loading...", quoteAuthor: "Author")
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
        
        let entry = SimpleEntry(
            date: Date(),
            quoteText: quoteText,
            quoteAuthor: quoteAuthor
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
        
        let entry = SimpleEntry(date: Date(), quoteText: quoteText, quoteAuthor: quoteAuthor)
        
        // Update daily at midnight
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quoteText: String
    let quoteAuthor: String
}

struct DailyQuoteWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.29, green: 0.56, blue: 0.89),
                    Color(red: 0.61, green: 0.35, blue: 0.71)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .center, spacing: 8) {
                Text(entry.quoteText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                
                Text("— \(entry.quoteAuthor)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding()
        }
        .widgetURL(URL(string: "quoteapp://daily"))
    }
}

@main
struct DailyQuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyQuoteWidget()
    }
}

