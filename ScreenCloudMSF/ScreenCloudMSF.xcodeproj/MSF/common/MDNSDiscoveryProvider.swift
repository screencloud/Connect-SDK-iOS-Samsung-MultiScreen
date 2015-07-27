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

class MDNSDiscoveryProvider: ServiceSearchProviderBase, NSNetServiceBrowserDelegate, NSNetServiceDelegate {

    // The service domain
    private let ServiceDomain = "local"

    // The multiscreen service type
    private let ServiceType = "_samsungmsf._tcp."

    // The raw network service (since the NetServices delegation methods are call in the main thread there is no need for a thread safe array)
    private var netServices = [NSNetService]()

    private var retryResolve = NSMutableSet()

    // The service browser
    private let serviceBrowser = NSNetServiceBrowser()

    required init(delegate: ServiceSearchProviderDelegate, id: String?) {
        super.init(delegate: delegate, id: id)
        type = ServiceSearchDiscoveryType.LAN
        serviceBrowser.delegate = self
    }

    // The deinitializer
    deinit {
        serviceBrowser.delegate = nil
    }

    // Start the search
    override func search() {
        // Cancel the previous search if any
        if isSearching {
            serviceBrowser.stop()
        }

        if id == nil {
            serviceBrowser.searchForServicesOfType(ServiceType, inDomain: ServiceDomain)
        } else {
            var aNetService = NSNetService(domain: ServiceDomain, type: ServiceType, name: id!)
            netServiceBrowser(serviceBrowser, didFindService: aNetService, moreComing: false)
        }

    }

    // Stops the search
    override func stop() {
        isSearching = false
        serviceBrowser.stop()
    }

    // MARK: - Service -

    func removeObject<T:Equatable>(inout arr:Array<T>, object:T) -> T? {
        if let found = find(arr,object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }

    private func removeService(aNetService: NSNetService!) {
        removeObject(&netServices, object: aNetService)
    }

    // MARK: - NSNetServiceBrowserDelegate  -

    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        isSearching = true
        delegate?.onStart(self)
    }

    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        delegate?.clearCacheForProvider(self)
        netServices.removeAll(keepCapacity: false) // clear the cache
        if isSearching {
            search()
        } else {
            delegate?.onStop(self)
        }
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        serviceBrowser.stop()
        netServiceBrowserDidStopSearch(aNetServiceBrowser)
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        if let found = find(netServices, aNetService) {
            println("ignoring \(netServices[found].name)")
        } else {
            aNetService.delegate = self
            aNetService.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            aNetService.resolveWithTimeout(NSTimeInterval(2))
            netServices.append(aNetService)
        }        
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        aNetService.stop()
        aNetService.delegate = nil
        removeService(aNetService)
        delegate?.onServiceLost(aNetService.name, discoveryType: self.type)
    }

    // MARK: - NSNetServiceDelegate  -

    func netService(aNetService: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        if id != nil {
            delegate?.onStop(self)
        } else if retryResolve.containsObject(aNetService.name) {
            retryResolve.removeObject(aNetService.name)
            removeService(aNetService)
        } else {
            retryResolve.addObject(aNetService.name)
            aNetService.resolveWithTimeout(NSTimeInterval(15))
        }
    }

    func netServiceDidResolveAddress(aNetService: NSNetService) {
        //The text record have the API root URI so the implementer can contruct the REST endpoint for App management
        if aNetService.addresses!.count > 0 {
            let txtRecord : NSDictionary = NSNetService.dictionaryFromTXTRecordData(aNetService.TXTRecordData()) as NSDictionary
            if let endpointData = txtRecord["se"] as? NSData {
                let endpoint: String = NSString(bytes: endpointData.bytes, length: endpointData.length, encoding: NSUTF8StringEncoding) as! String
                let uuidData = txtRecord["id"] as! NSData
                let uuid: String = NSString(bytes: uuidData.bytes, length: uuidData.length, encoding: NSUTF8StringEncoding) as! String
                delegate!.onServiceFound(uuid, serviceURI: endpoint, discoveryType: ServiceSearchDiscoveryType.LAN)
            }
        }
        //release resources
        aNetService.delegate = nil
        removeService(aNetService)
    }

}