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

class MSFDiscoveryProvider: ServiceSearchProviderBase {

    private enum MSFDMessageType: String {
        case Up =       "up"
        case Alive =    "alive"
        case Dowm =     "down"
        case Discover = "discover"
    }

    private let MULTICAST_ADDRESS   = "224.0.0.7"
    private let MULTICAST_TTL       = 1
    private let MULTICAST_PORT:UInt16   = 8001
    private let MAX_MESSAGE_LENGTH:UInt16  = 2000
    private let TBEAT_INTERVAL = NSTimeInterval(1)
    private let RETRY_COUNT = 3
    private let RETRY_INTERVAL = 1

    private var udpSearchSocket: GCDAsyncUdpSocket!
    private var udpListeningSocket: GCDAsyncUdpSocket!

    //private var unresolvedServices = NSMutableSet(capacity: 0)
    private var services = NSMutableDictionary(capacity: 0)
    private var timer: NSTimer!

    private var isRestarting = false

    private let accessQueue = dispatch_queue_create("MSFDiscoveryProviderQueue", DISPATCH_QUEUE_SERIAL)
    // The intializer
    required init(delegate: ServiceSearchProviderDelegate, id: String?) {
        super.init(delegate: delegate, id: id)
        type = ServiceSearchDiscoveryType.LAN
    }

    /// Start the search
    override func search() {
        dispatch_async(self.accessQueue) { [unowned self] in
            var error: NSError? = nil

            self.udpListeningSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.accessQueue)
            self.udpListeningSocket.setIPv6Enabled(false)
            self.udpListeningSocket.setMaxReceiveIPv4BufferSize(self.MAX_MESSAGE_LENGTH)

            self.udpListeningSocket.bindToPort(self.MULTICAST_PORT, error: &error)
            if error != nil {
                println("udpListeningSocket bindToPort \(error)")
            }


            self.udpListeningSocket.joinMulticastGroup(self.MULTICAST_ADDRESS, error: &error)
            if error != nil {
                println("udpListeningSocket joinMulticastGroup \(error)")
            }

            self.udpListeningSocket.beginReceiving(&error)
            if error != nil {
                println("udpListeningSocket  beginReceiving \(error)")
            }

            self.udpSearchSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.accessQueue)
            self.udpSearchSocket.setIPv6Enabled(false)
            self.udpSearchSocket.setMaxReceiveIPv4BufferSize(self.MAX_MESSAGE_LENGTH)

            self.udpSearchSocket.bindToPort(0, error: &error)
            if error != nil {
                println("udpSearchSocket  bindToPort \(error)")
            }

            self.udpSearchSocket.beginReceiving(&error)
            if error != nil {
                println("udpSearchSocket  beginReceiving \(error)")
            }

            self.udpSearchSocket.sendData(self.getMessageEnvelope(), toHost: self.MULTICAST_ADDRESS, port: self.MULTICAST_PORT, withTimeout: NSTimeInterval(-1), tag: 0)

            // if not searching by id
            if self.id == nil {
                dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(self.TBEAT_INTERVAL, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
                }
            }
            self.isSearching = true
        }
    }

    func update() {
        dispatch_async(self.accessQueue) { [unowned self] in
            let now = NSDate()
            let keys = NSArray(array: self.services.allKeys) as! [String]
            for key in keys {
                if self.services[key]?.compare(now) == NSComparisonResult.OrderedAscending {
                    self.services.removeObjectForKey(key)
                    println("MSFD -> self.services \(key) \(self.services)")
                    self.delegate?.onServiceLost(key, discoveryType: self.type)
                }
            }
        }
    }

    /// Stops the search
    override func stop() {
        dispatch_sync(self.accessQueue) { [unowned self] in
            if self.isSearching {
                self.isSearching = false
                if self.timer != nil {
                    self.timer.invalidate()
                    self.timer = nil
                }

                var error: NSError? = nil

                self.udpListeningSocket.leaveMulticastGroup(self.MULTICAST_ADDRESS, error: &error)
                self.udpListeningSocket = nil

                self.udpSearchSocket = nil

                self.services.removeAllObjects()
                //self.unresolvedServices.removeAllObjects()

                //delegate?.onStop(self)
            }
        }
    }

    override func serviceResolutionFaile(serviceId: String, discoveryType: ServiceSearchDiscoveryType) {
        if discoveryType == type {
            dispatch_async(self.accessQueue) { [unowned self] in
                self.services.removeObjectForKey(serviceId)
            }
        }
    }

    /**
    * Called when the datagram with the given tag has been sent.
    **/
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {

    }

    /**
    * Called if an error occurs while trying to send a datagram.
    * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
    **/
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {

    }

    /**
    * Called when the socket has received the requested datagram.
    **/
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        if let msg: [String:AnyObject] = JSON.parse(data: data) as? Dictionary {
            if let type: MSFDMessageType = MSFDMessageType(rawValue: msg["type"] as! String) {
                switch type {
                case .Up:
                    serviceFound(msg)
                case .Alive:
                    serviceFound(msg)
                default: ()
                }
            }
        }
    }

    /**
    * Called when the socket is closed.
    **/
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        if isSearching {
            isRestarting = true
            self.stop()
            self.delegate?.clearCacheForProvider(self)
            self.search()
        } else if !isRestarting {
            isSearching = false
            delegate?.onStop(self)
        }
    }

    private func serviceFound(msg: NSDictionary) {
        if let sid = msg["sid"] as? String {
            if (id != nil && id == sid) || id == nil {
                if let uri = msg.objectForKey("data")?.objectForKey("v2")?.objectForKey("uri") as? String {
                    let ttl = msg["ttl"] as! Double
                    if services[sid] == nil {
                        println("MSFD -> serviceFound \(sid) \(uri)")
                        services[sid] = NSDate(timeIntervalSinceNow: NSTimeInterval(ttl/1000.0))
                        delegate!.onServiceFound(sid, serviceURI: uri, discoveryType: ServiceSearchDiscoveryType.LAN)
                    } else {
                        self.services[sid] = NSDate(timeIntervalSinceNow: NSTimeInterval(ttl/1000.0))
                    }
                }
            }
        }
    }

    private func getMessageEnvelope() -> NSData {
        var msg: [String: AnyObject] = [
            "type": MSFDMessageType.Discover.rawValue,
            "data": [:],
            "cuid":  NSUUID().UUIDString
        ]
        return JSON.jsonDataForObject(msg)!
    }



}