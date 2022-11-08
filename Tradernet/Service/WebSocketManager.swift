import Starscream

protocol WebSocketManagerDelegate: AnyObject {
    func receiveUpdate(info: StockInfo)
    func connectionError(error: Error?)
}

class WebSocketManager {
    let socketUrl = URL(string: "wss://wss.tradernet.ru")!
    var isConnected = false
    let socket: WebSocket
    let quotes = "[\"quotes\",[\"TRNFP\",\"TATNP\",\"TATN\",\"AAPL.SPB\",\"SU52001RMFS3\",\"SU29011RMFS2\",\"SU26216RMFS0\",\"SU26215RMFS2\",\"SU26212RMFS9\",\"SU26207RMFS9\",\"SU25077RMFS7\"]]"
    
    weak var delegate: WebSocketManagerDelegate?
    
    init() {
        var request = URLRequest(url: socketUrl)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func sendQuotes() {
        socket.write(string: quotes) {
            print("sent")
        }
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            sendQuotes()
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            do {
                let jsonString = string.replacingOccurrences(of: "[\"q\",", with: "")
                    .replacingOccurrences(of: "]", with: "")
                let jsonData = jsonString.data(using: .utf8)!
                let stockInfo = try JSONDecoder().decode(StockInfo.self, from: jsonData)
                delegate?.receiveUpdate(info: stockInfo)
            } catch {}
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            delegate?.connectionError(error: error)
        }
    }
}
