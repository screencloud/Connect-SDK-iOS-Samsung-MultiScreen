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

///  A client currently connected to the channel
@objc public class ChannelClient: Printable, Equatable {

    var clientInfo: [String:AnyObject]

    /// The id of the client
    public var id: String {
        let id: AnyObject? = clientInfo["id"]
        return id as! String!
    }

    /// The time which the client connected in epoch milliseconds
    public var connectTime: Int {
        let connectTime: AnyObject? = clientInfo["connectTime"]
            return connectTime as! Int!
    }

    /// A dictionary of attributes passed by the client when connecting
    public var attributes: AnyObject? {
        let attributes: AnyObject? = clientInfo["attributes"]
            return attributes
    }

    /// Flag for determining if the client is the host
    public var isHost: Bool {
        let isHost: AnyObject? = clientInfo["isHost"]
            return isHost as! Bool!
    }

    /// The description of the client
    public var description: String {
        get {
            return "id: \(id) isHost \(isHost)"
        }
    }

    ///  The initializer
    ///
    ///  :param: clientInfo: A dictionary with the client information
    ///
    ///  :returns: A ChannelClient instance
    internal init (clientInfo: [String:AnyObject]) {
        self.clientInfo = clientInfo
    }
}

public func == (lhs: ChannelClient, rhs: ChannelClient) -> Bool {
    return lhs.id == rhs.id
}