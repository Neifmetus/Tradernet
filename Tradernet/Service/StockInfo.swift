import Foundation

struct StockInfo: Decodable {
    let c: String
    let ltr: String?
    let name2: String?
    // change in percents
    var pcp: Double?
    // Last price
    var ltp: Double?
    // change in points
    var chg: Double?
}
