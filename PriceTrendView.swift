import SwiftUI
import Charts
import RealmSwift

struct PriceTrendView: View {
    @ObservedResults(PriceHistory.self) var history
    var property: Property

    var body: some View {
        let filtered = history.filter { $0.propertyID == property.id }
            .sorted(by: { $0.date < $1.date })
        
        VStack(alignment: .leading) {
            Text("Price Trend")
                .font(.title2.bold())
                .padding(.bottom, 8)

            if filtered.isEmpty {
                Text("No price data available.")
                    .foregroundColor(.gray)
            } else {
                Chart(filtered) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Price", item.price)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Price", item.price)
                    )
                }
                .frame(height: 250)
                .padding()
            }
        }
        .padding()
    }
}

struct SelectPropertyForTrendView: View {
    @ObservedResults(Property.self) var properties

    var body: some View {
        List(properties) { property in
            NavigationLink(property.title) {
                PriceTrendView(property: property)
            }
        }
        .navigationTitle("Select Property")
    }
}
