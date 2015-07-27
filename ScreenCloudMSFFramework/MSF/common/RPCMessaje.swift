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

class RPCMessage {

    var message: [String:AnyObject]! = nil

    var id: String! {
        return message["id"] as! String
    }

    var result: [String:AnyObject]? {
        return message["result"] as? [String:AnyObject]
    }

    var error: NSError? {
        if let err: [String:AnyObject] = message["error"] as? [String:AnyObject] {
            let code = err["code"] as! Int
            let message = err["message"] as! String
            let rpcError = NSError(domain: "Channel Error", code: code, userInfo: [NSLocalizedDescriptionKey:message])
            return rpcError
        }
        return nil
    }

    init (message: [String:AnyObject]) {
        self.message = message
    }

}