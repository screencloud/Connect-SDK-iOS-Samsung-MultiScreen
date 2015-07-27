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


class WebSocketTransport: ChannelTransport, WebSocketDelegate {
    var isConnecting = false
    var socket: WebSocket!
    var url: String
    weak var delegate: ChannelTransportDelegate!

    required init (url: String, service: Service?) {
        self.url = url
    }

    func close() {
        socket?.disconnect()
    }

    func close(#force: Bool) {
        if socket != nil && socket!.isConnected {
            socket?.disconnectStream(nil)
        }
    }

    func connect(options: [String:String]?) {
        isConnecting = true
        var optionsString = ""
        if options != nil {
            optionsString = "?"
            for (key,value) in options! {
                optionsString += "\(key)=\(value)&"
            }
        }
        socket = WebSocket(url: NSURL(string: NSString(string:  url + optionsString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)
        socket!.delegate = self
        socket!.connect()
    }

    func send(message: String) {
        socket?.writeString(message)
    }

    func sendData(data: NSData) {
        socket?.writeData(data)
    }


    //MARK: - WebsocketDelegate -


    func websocketDidConnect(socket: WebSocket) {
        isConnecting = false
        delegate?.didConnect(nil)
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if isConnecting  {
            isConnecting = false
            delegate?.didConnect(error)
        } else {
            if error != nil && error!.code == 1000 {
                delegate?.didDisconnect(nil)
            } else {
                delegate?.didDisconnect(error)
            }
        }
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        delegate.processTextMessage(text)
    }

    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        delegate.processDataMessage(data)
    }

}