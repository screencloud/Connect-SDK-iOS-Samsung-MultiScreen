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

///  This emumeration defines the target option for the emit methods, use this
///  definitions in addition to the client id or a collection of client ids
///
///  - All:       Target all the clients including the host and the sender
///  - Host:      Target only the host
///  - Broadcast: Target all the clients including the host and the sender
public enum MessageTarget: String {
    case All = "all"
    case Host = "host"
    case Broadcast = "broadcast"
}

///  This emumeration defines the notification options for a channel, this is an
///  alternative to the ChannelDelegate protocol.
///
///  Use this channel event enumeration in conjunction with the channel.on(...) and channel.off(...)
///  methods in order to receive the notifications in a closure in the main thread
///
///
///
///  - Connect:          The on connect event
///  - Disconnect:       The on disconnect event
///  - ClientConnect:    A client connect event
///  - ClientDisconnect: A client disconnect event
///  - Message:          A text message was received
///  - Data:             A binary data message was received
///  - Error:            An error happened
///  - Ready:            The host app is ready to send or receive messages
public enum ChannelEvent : String {
    case Connect = "ms.channel.connect"
    case Disconnect = "ms.channel.disconnect"
    case ClientConnect = "ms.channel.clientConnect"
    case ClientDisconnect = "ms.channel.clientDisconnect"
    case Message = "ms.channel.message"
    case Data = "ms.channel.data"
    case Error = "ms.error"
    case Ready = "ms.channel.ready"
    case Ping = "ms:channel.ping"
}

///  @brief  RPCResultHandler is a container class for the result callback of RPC invocations
///
///  @since 2.0
class RPCResultHandler {
    var handler: ((message: RPCMessage) -> Void)
    init (handler: ((message: RPCMessage) -> Void)) {
        self.handler = handler
    }
}

///  The channel delegate protocol defines the event methods available for a channel
@objc public protocol ChannelDelegate: class {
    ///  Called when the Channel is connected
    ///
    ///  :param: client: The Client that just connected to the Channel
    ///
    ///  :param: error: An error info if any
    optional func onConnect(client: ChannelClient?, error: NSError?)

    ///  Called when the host app is ready to send or receive messages
    ///
    ///
    optional func onReady()

    ///  Called when the Channel is disconnected
    ///
    ///  :param: client The Client that just disconnected from the Channel
    ///
    ///  :param: error: An error info if any
    optional func onDisconnect(client: ChannelClient?, error: NSError?)

    ///  Called when the Channel receives a text message
    ///
    ///  :param: message: Text message received
    optional func onMessage(message: Message)

    ///  Called when the Channel receives a binary data message
    ///
    ///  :param: message: Text message received
    ///  :param: payload: Binary payload data
    optional func onData(message: Message, payload: NSData)

    ///  Called when a client connects to the Channel
    ///
    ///  :param: client: The Client that just connected to the Channel
    optional func onClientConnect(client: ChannelClient)

    ///  Called when a client disconnects from the Channel
    ///
    ///  :param: client: The Client that just disconnected from the Channel
    optional func onClientDisconnect(client: ChannelClient)

    ///  Called when a Channel Error is fired
    ///
    ///  :param: error: The error
    optional func onError(error: NSError)
}

///  A Channel is a discreet connection where multiple clients can communicate
///
///  :since: 2.0
@objc public class Channel: ChannelTransportDelegate {

    ///  The availble methods for the channel
    ///
    ///  - Emit: The method to emit an event
    private enum ChannelMethod : String {
        case Emit = "ms.channel.emit"
    }

    /// The connection status of the channel
    public private(set)  var isConnected: Bool = false

    // The transport used for the channel connection
    private var transport: ChannelTransport! = nil

    // The collection of result handlers for RPC invocations
    private var rpcHandlers = [String: RPCResultHandler]()

    /// The uri of the channel ('chat')
    public private(set) var uri: String! = nil

    /// the service that is suplaying the channel connection
    public private(set) var service : Service! = nil

    /// The timeout for channel transport connection
    /// the connection will be closed if no ping is received within the defined timeout
    public var connectionTimeout: NSTimeInterval = 0 {
        didSet {
            stopConnectionAliveCheck()
            startConnectionAliveCheck()
        }
    }

    /// The client that owns this channel instance
    public var me: ChannelClient!

    /// The collection of clients currently connected to the channel
    internal var clients: [ChannelClient] = []

    /// The delegate for handling channel events, alternative
    weak public var delegate: ChannelDelegate? = nil

    private var pingTimer: NSTimer? = nil

    private var lastPingDate: NSDate? = nil

    ///  Internal initializer
    ///
    ///  :param: url     The endpoint for the channel
    ///  :param: service The serivice providing the connectivity
    ///
    ///  :returns: A channel instance
    ///
    internal init(uri: String, service :Service) {
        self.uri = uri
        self.service = service
        let channelURL = service.uri + "channels/" + self.uri
        transport = ChannelTransportFactory.channelTrasportForType(channelURL, service: service)
        transport.delegate = self
    }

    ///  sendRPC invokes a remote method
    ///
    ///  :param: method  The method to be invoked
    ///  :param: params  The parameters for the remote procedure
    ///  :param: handler The response/result closure
    ///
    internal func sendRPC(method: String, params: [String:AnyObject]?, handler: ((message: RPCMessage) -> Void) ) {
        let uuid = NSUUID().UUIDString
        var messageEnvelope = [String:AnyObject]()
        messageEnvelope["id"] = uuid
        messageEnvelope["method"] = method
        if params != nil {
            messageEnvelope["params"] = params
        }
        if let stringMessage = JSON.stringify(messageEnvelope) {
            transport.send(stringMessage)
            rpcHandlers[uuid] = RPCResultHandler(handler: handler)
        }
    }

    ///  Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a
    ///  ChannelEvent.Connect notification upon completion.
    ///  When a TV application connects to this channel, the onReady method/notification is also fired
    ///
    public func connect() {
        connect(nil)
    }

    ///  Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a
    ///  ChannelEvent.Connect notification upon completion.
    ///  When a TV application connects to this channel, the onReady method/notification is also fired
    ///
    ///  :param: attributes Any attributes you want to associate with the client (ie. ["name":"FooBar"])
    ///
    public func connect(attributes: [String:String]?) {
        connect(attributes, completionHandler: nil)
    }

    ///  Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a
    ///  ChannelEvent.Connect notification upon completion.
    ///  When a TV application connects to this channel, the onReady method/notification is also fired
    ///
    ///  :param: attributes        Any attributes you want to associate with the client (ie. ["name":"FooBar"])
    ///  :param: completionHandler The callback handler
    ///
    public func connect(attributes: [String:String]?, completionHandler: ((client: ChannelClient?, error: NSError?) -> Void)!) {
        var observer: AnyObject!
        if completionHandler != nil {
            observer = on(ChannelEvent.Connect.rawValue) { [unowned self] (notification) -> Void in
                self.off(observer)
                let userInfo: [String:AnyObject] = notification!.userInfo as! [String:AnyObject]
                let client: ChannelClient = userInfo["client"] as! ChannelClient
                let error: NSError? = notification!.userInfo?["error"] as? NSError
                completionHandler(client: client, error: error)
            }
        }
        transport.connect(attributes)
    }

    ///  Disconnects from the channel. This method will asynchronously call the delegate's onDisconnect and post a
    ///  ChannelEvent.Disconnect notification upon completion.
    ///
    ///  :param: completionHandler: The callback handler
    ///
    ///   - client: The client that is disconnecting which is yourself
    ///   - error: An error info if disconnect fails
    public func disconnect(completionHandler: ((client: ChannelClient?, error: NSError?) -> Void)!) {
        if completionHandler != nil {
            var observer: AnyObject!
            observer = on(ChannelEvent.Disconnect.rawValue) { [unowned self] (notification) -> Void in
                self.off(observer)
                let userInfo: [String:AnyObject] = notification!.userInfo as! [String:AnyObject]
                let client: ChannelClient = userInfo["client"] as! ChannelClient
                let error: NSError? = notification!.userInfo?["error"] as? NSError
                completionHandler(client: client, error: error)
            }
        }
        transport.close()
    }

    ///  Disconnects from the channel. This method will asynchronously call the delegate's onDisconnect and post a
    ///  ChannelEvent.Disconnect notification upon completion.
    ///
    public func disconnect() {
        disconnect(nil)
    }

    ///  Publish an event containing a text message payload
    ///
    ///  :param: event:   The event name
    ///  :param: message: A JSON serializable message object
    public func publish(#event: String, message: AnyObject?) {
        emit(event: event, message: message, target: MessageTarget.Broadcast.rawValue, data: nil)
    }

    ///  Publish an event containing a text message and binary payload
    ///
    ///  :param: event:   The event name
    ///  :param: message: A JSON serializable message object
    ///  :param: data:    Any binary data to send with the message
    public func publish(#event: String, message: AnyObject?, data: NSData) {
        emit(event: event, message: message, target: MessageTarget.Broadcast.rawValue, data: data)
    }

    ///  Publish an event with text message payload to one or more targets
    ///
    ///  :param: event:   The event name
    ///  :param: message: A JSON serializable message object
    ///  :param: target:  The target recipient(s) of the message.Can be a string client id, a collection of ids or a string MessageTarget (like MessageTarget.All.rawValue)
    public func publish(#event: String, message: AnyObject?, target: AnyObject) {
        emit(event: event, message: message, target: target, data: nil)
    }

    ///  Publish an event containing a text message and binary payload to one or more targets
    ///
    ///  :param: event:   The event name
    ///  :param: message: A JSON serializable message object
    ///  :param: data:    Any binary data to send with the message
    ///  :param: target:  The target recipient(s) of the message.Can be a string client id, a collection of ids or a string MessageTarget (like MessageTarget.All.rawValue)
    public func publish(#event: String, message: AnyObject?, data: NSData, target: AnyObject ) {
        emit(event: event, message: message, target: target, data: data)
    }

    /// A snapshot of the list of clients currently connected to the channel
    public func getClients() -> [ChannelClient] {
        let clientList = NSArray(array: clients)
        return clientList as! [ChannelClient]
    }

    internal func emit(#event: String, message: AnyObject?, target: AnyObject, data: NSData?) {
        if let messageEnvelope = getMessageEnvelope(ChannelMethod.Emit.rawValue, event: event, message: message, target: target) {
            if let stringMessage = JSON.stringify(messageEnvelope) {
                if data == nil {
                    transport.send(stringMessage)
                } else {
                    transport.sendData(encodeMessage(stringMessage, payload: data!))
                }
            } else {
                //TODO: report an error
                println("Unable to serialize the message")
            }
        }
    }

    ///  A convenience method to subscribe for notifications using blocks
    ///
    ///  :param: notificationName: The name of the notification
    ///  :param: performClosure:   The notification block, this block will be executed in the main thread
    ///
    ///  :returns: An observer handler for removing/unsubscribing the block from notifications
    public func on(notificationName: String, performClosure:(NSNotification!) -> Void) -> AnyObject? {
        return NSNotificationCenter.defaultCenter().addObserverForName(notificationName, object: self, queue: NSOperationQueue.mainQueue(), usingBlock: performClosure)
    }

    ///  A convenience method to unsubscribe from notifications
    ///
    ///  :param: observer: The observer object to unregister observations
    public func off(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

    // MARK: - Private Methods -

    private func getMessageEnvelope(method: String, event: String, message: AnyObject?, target: AnyObject, id: String? = nil) -> [String:AnyObject]? {
        var anyTarget: AnyObject? = nil
        switch target {
        case let idTarget as String:
            anyTarget = idTarget
        case let arrayTarget as [String]:
            if arrayTarget.count < 0 {
                anyTarget = arrayTarget
            }
        case let clientTarget as ChannelClient:
            anyTarget = clientTarget.id
        case let clientsTarget  as [ChannelClient]:
            if clientsTarget.count < 0 {
                var clientIds = [String]()
                for client in clientsTarget {
                    clientIds.append(client.id)
                }
                anyTarget = clientIds
            }
        default:
            return nil
        }

        var envelope = [String:AnyObject]()

        envelope["method"] = method

        if id != nil && id?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            envelope["id"] = id
        }

        var params = [String:AnyObject]()
        params["to"] = anyTarget!
        params["event"] = event

        if message != nil {
            params["data"] =  message!
        }

        envelope["params"] = params

        return envelope
    }

    private func encodeMessage(message: String, payload: NSData) -> NSData {
        let head: NSData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let data: NSMutableData = NSMutableData()
        var headByteLen = UInt16(head.length).bigEndian
        data.appendBytes(&headByteLen, length: sizeof(UInt16))
        data.appendData(head)
        data.appendData(payload)
        return data
    }

    private func decodeMessage(data: NSData) -> [String:AnyObject]? {
        var headByteLen: UInt16 = 0; data.getBytes(&headByteLen, length: sizeof(UInt16))
        let headLen =  Int(UInt16(bigEndian: headByteLen))
        let messageData = data.subdataWithRange(NSMakeRange(2, headLen))
        if let message = NSString(data: messageData, encoding: NSUTF8StringEncoding) {
            var payload = data.subdataWithRange(NSMakeRange(headLen + 2, data.length - 2 - headLen ))
            return ["message": message, "payload": payload]
        } else {
            return nil
        }
    }

    private func removeObject<T:Equatable>(inout arr:Array<T>, object:T) -> T? {
        if let found = find(arr,object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }

    func processRPCMessage(message: RPCMessage) {
        if let handler = rpcHandlers[ message.id ] {
            handler.handler(message: message)
            rpcHandlers.removeValueForKey(message.id)
        }
    }

    func processMessage(message: Message) {
        if let event = ChannelEvent(rawValue: message.event) {
            let now = NSDate()
            switch event {
            case .Connect:
                let id = message.data!.valueForKeyPath("id") as? String
                let clientsArray: [[String:AnyObject]]! = message.data!.valueForKeyPath("clients") as? [[String:AnyObject]]
                for clientDictionary in clientsArray {
                    let client = ChannelClient(clientInfo: clientDictionary)
                    if id == client.id {
                        me = client
                    }
                    clients.append(client)
                }
                if NSStringFromClass(self.dynamicType) == NSStringFromClass(Channel.self) {
                    isConnected = true
                    startConnectionAliveCheck()
                    delegate?.onConnect?(me, error: nil)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: message.event, object: self, userInfo: ["client": me] ))
                }
            case .ClientConnect:
                let client = ChannelClient(clientInfo: message.data as! [String:AnyObject])
                clients.append(client)
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: message.event, object: self, userInfo: ["client": client]))
                delegate?.onClientConnect?(client)
            case .ClientDisconnect:
                let clientId = message.data!["id"] as! String
                let found = self.clients.filter{$0.id == clientId}
                if found.count > 0 {
                    let client = found[0]
                    removeObject(&clients, object: client)
                    delegate?.onClientDisconnect?(client)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: message.event, object: self, userInfo: ["client":client]))
                }
            case .Ping:
                lastPingDate = NSDate()
            case .Ready:
                if NSStringFromClass(self.dynamicType) != NSStringFromClass(Channel.self) {
                    isConnected = true
                    startConnectionAliveCheck()
                    delegate?.onConnect?(me, error: nil)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ChannelEvent.Connect.rawValue, object: self, userInfo: ["client": me] ))
                }
                delegate?.onReady?()
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: message.event, object: self))
            case .Error:
                let channelError = NSError(domain: "Channel Error", code: -1, userInfo: [NSLocalizedDescriptionKey:message.data!["message"] as! String])
                delegate?.onError?(channelError)
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: message.event, object: self, userInfo: ["error":channelError]))
            default:
                println("unhandled message event?")
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: message.event, object: self, userInfo: ["message":message]))
            delegate?.onMessage?(message)
        }
    }

    // MARK: - WebsocketDelegate Methods -
    func processTextMessage(message: String) {
        if let result: [String:AnyObject] = JSON.parse(jsonString: message) as? [String:AnyObject] {
            if let id: AnyObject = result["id"] {
                let message = RPCMessage(message: result)
                processRPCMessage(message)
            } else {
                let message = Message(message: result)
                processMessage(message)
            }
        }
    }

    func processDataMessage(data: NSData) {
        if let unwrappedData = decodeMessage(data) {
            let message: String? = unwrappedData["message"]! as? String
            let result: [String:AnyObject]? = JSON.parse(jsonString: message!) as? [String:AnyObject]
            let messageObject = Message(message: result!)
            let payload: NSData? = unwrappedData["payload"]! as? NSData
            delegate?.onData?(messageObject, payload: payload!)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: messageObject.event, object: self, userInfo: ["message":messageObject,"payload":payload!]))
        } else {
            //TODO: add an error definition for malformed binary envelope exception
        }
    }

    func didConnect(error: NSError?) {
        if error != nil {
            delegate?.onConnect?(nil, error: error)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ChannelEvent.Connect.rawValue, object: self, userInfo: ["client": NSNull()] ))
        }
    }

    func didDisconnect(error: NSError?) {
        if isConnected {
            stopConnectionAliveCheck()
            clients.removeAll(keepCapacity: false)
            isConnected = false
            dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                if self.delegate != nil {
                    self.delegate!.onDisconnect?(self.me, error: error)
                }
            }
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ChannelEvent.Disconnect.rawValue, object: self, userInfo: ["client":me]))
            me = nil
        }
    }

    func onError(error: NSError) {

    }

    // MARK: -  connection timeout methods -

    private func stopConnectionAliveCheck() {
        if pingTimer != nil {
            pingTimer?.invalidate()
            pingTimer = nil
        }
    }

    private func startConnectionAliveCheck() {
        if connectionTimeout > 0 {
            if isConnected && self.me != nil {
                lastPingDate = nil
                dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                    self.pingTimer = NSTimer.scheduledTimerWithTimeInterval(self.connectionTimeout, target: self, selector: Selector("checkConnectionAlive"), userInfo: nil, repeats: true)
                    self.emit(event: ChannelEvent.Ping.rawValue, message: "", target: self.me, data: nil)
                }
            }
        }
    }

    internal func checkConnectionAlive() {
        if lastPingDate == nil {
            stopConnectionAliveCheck()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) { [unowned self]  () -> Void in
                self.transport.close(force: true)
            }
        } else {
            if isConnected && me != nil {
                lastPingDate = nil
                emit(event: ChannelEvent.Ping.rawValue, message: "", target: me, data: nil)
            }
        }
    }

}


