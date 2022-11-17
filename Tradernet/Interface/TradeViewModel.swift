import Foundation

enum PriceShiftState {
    case positive
    case negative
    case noDiff
}

struct Stock {
    let ticker: String
    var stocksInfo: String
    var price: Double?
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
            let isEqual = stocks[$0].ticker == info.c
            if isEqual {
                let newPrice = getPrice(value: info.pcp)
                let priceDiff = getPriceDiff(lastPrice: info.ltp, change: info.chg)
                let stocksInfo = getStockInfo(market: info.ltr, name: info.name2)
                if !stocksInfo.isEmpty {
                    stocks[$0].stocksInfo = stocksInfo
                }
                stocks[$0].priceShift = ((newPrice ?? 0) > (stocks[$0].price ?? 0)) ? .positive : .negative
                if newPrice != nil {
                    stocks[$0].price = newPrice
                }
                if !priceDiff.isEmpty {
                    stocks[$0].priceDiff = priceDiff
                }
                stockExists = true
                if let updatedStockIndex = updatedStockIndex {
                    stocks[updatedStockIndex].priceShift = .noDiff
                    delegate?.updateStockInfo(index: updatedStockIndex)
                }
                updatedStockIndex = $0
                delegate?.updateStockInfo(index: $0)
            }
        }
        
        if !stockExists {
            let price = getPrice(value: info.pcp)
            let priceDiff = getPriceDiff(lastPrice: info.ltp, change: info.chg)
            let stocksInfo = getStockInfo(market: info.ltr, name: info.name2)
            stocks.append(Stock(ticker: info.c,
                                stocksInfo: stocksInfo,
                                price: price,
                                priceDiff: priceDiff))
            delegate?.addNewStock()
        }
    }

    func connectionError(error: Error?) {}
    
    // MARK: Private
    private func getPrice(value: Double?) -> Double? {
        if let value = value {
            return Double(round(100 * value) / 100)
        }
        return nil
    }
    
    private func getStockInfo(market: String?, name: String?) -> String {
        var result = ""
        if let market = market, !market.isEmpty {
            result += "\(market)"
        }
        
        if let name = name, !name.isEmpty {
            result += !result.isEmpty ? " " : ""
            result += "| \(name)"
        }
        
        return result
    }
    
    private func getPriceDiff(lastPrice: Double?, change: Double?) -> String {
        var result = ""
        if let lastPrice = lastPrice {
            result += "\(lastPrice)"
        }
        
        if let change = change {
            result += !result.isEmpty ? " " : ""
            result += "(\(change))"
        }
        return result
    }
}
