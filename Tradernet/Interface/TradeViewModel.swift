import Foundation

enum PriceShiftState {
    case positive
    case negative
    case noDiff
}

struct Stock {
    let name: String
    let stocksInfo: String
    var price: Double
    var priceDiff: String
    var priceShift: PriceShiftState = .noDiff
}

protocol TradeViewModelDelegate: AnyObject {
    func addNewStock()
    func updateStockInfo(index: Int)
}

class TradeViewModel {
    let manager: WebSocketManager
    var stocks: [Stock] = []
    var updatedStockIndex: Int?
    
    weak var delegate: TradeViewModelDelegate?
    
    init() {
        manager = WebSocketManager()
        manager.delegate = self
    }
}

extension TradeViewModel: WebSocketManagerDelegate {
    func receiveUpdate(info: StockInfo) {
        if let index = updatedStockIndex {
            stocks[index].priceShift = .noDiff
            delegate?.updateStockInfo(index: index)
        }
        
        var stockExists = false
        stocks.indices.forEach {
            let isEqual = stocks[$0].name == info.name2
            if isEqual, let pcp = info.pcp {
                let newPrice = round(pcp * 100) / 100.0
                stocks[$0].priceShift = (newPrice > stocks[$0].price) ? .positive : .negative
                stocks[$0].price = newPrice
                stockExists = true
                updatedStockIndex = stocks.count - 1
                delegate?.updateStockInfo(index: $0)
            }
        }
        
        if !stockExists {
            if let name = info.name2,
               let stocksInfo = info.ltr,
               let price = info.pcp,
               let lastPrice = info.ltp,
               let priceDiff = info.chg
            {
                stocks.append(Stock(name: name,
                                    stocksInfo: stocksInfo,
                                    price: Double(round(100 * price) / 100),
                                    priceDiff: "\(lastPrice) (\(priceDiff))"))
                delegate?.addNewStock()
            }
        }
    }
    
    func connectionError(error: Error?) {}
    
}
