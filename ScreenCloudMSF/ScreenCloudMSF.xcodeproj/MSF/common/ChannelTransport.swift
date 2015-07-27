/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import Foundation

protocol ChannelTransportDelegate: class {
    func processTextMessage(message: String)
    func processDataMessage(data: NSData)
    func didConnect(error: NSError?)
    func didDisconnect(error: NSError?)
    func onError(error: NSError)
}

protocol ChannelTransport {
    weak var delegate: ChannelTransportDelegate! {get set}
    init (url: String, service: Service?)
    func close()
    func close(#force: Bool)
    func connect(options: [String:String]?)
    func send(message: String)
    func sendData(data: NSData)
}

enum ChannelTransportType {
    case WebSocket
}

class ChannelTransportFactory {
    class func channelTrasportForType(url: String, service: Service?) -> ChannelTransport {
        if (service != nil) {
            switch service!.transportType {
            case .WebSocket:
                return  WebSocketTransport(url: url, service: service)
            }
        } else {
            return  WebSocketTransport(url: url, service: service)
        }
    }
}

