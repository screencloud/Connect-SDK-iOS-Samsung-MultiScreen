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

typealias RequestCompletionHandler = (responseHeaders: [String:String]?, data: NSData?, error: NSError?) -> Void

class Requester {

    /// Create and send a POST HTTP request
    ///
    /// :param: url The end point's URL
    /// :param: payload The data to be POST is treared as Content-Type: text/plain; charset=utf-8 and it can be override by setting the headers dictionary
    /// :param: headers Additional headers set for the request
    /// :param: timeout The timeout for the request
    /// :param: completionHandler The response completion closure, it will be executed in the request queue i.e. in a backgound thread
    class func doPost(url: String, payload: NSData!, headers: Dictionary<String,String>!, timeout: NSTimeInterval,  completionHandler: RequestCompletionHandler) -> Void {
        doRequest(url, method: "POST", payload: payload, headers: headers, timeout: timeout, completionHandler: completionHandler);
    }

    /// Create and send a PUT HTTP request
    ///
    /// :param: url The end point's URL
    /// :param: payload The data to be PUT is treared as Content-Type: text/plain; charset=utf-8 and it can be override by setting the headers dictionary
    /// :param: headers Additional headers set for the request
    /// :param: timeout The timeout for the request
    /// :param: completionHandler The response completion closure, it will be executed in the request queue i.e. in a backgound thread
    class func doPut(url: String, payload: NSData!, headers: Dictionary<String,String>!, timeout: NSTimeInterval,  completionHandler: RequestCompletionHandler) -> Void {
        doRequest(url, method: "PUT", payload: payload, headers: headers, timeout: timeout, completionHandler: completionHandler);
    }

    /// Create and send a GET HTTP request
    ///
    /// :param: url The end point's URL
    /// :param: headers Additional headers set for the request
    /// :param: timeout The timeout for the request
    /// :param: completionHandler The response completion closure, it will be executed in the request queue i.e. in a backgound thread
    class func doGet(url: String, headers: Dictionary<String,String>!, timeout: NSTimeInterval, completionHandler: RequestCompletionHandler) {
        doRequest(url, method: "GET", payload: nil, headers: headers, timeout: timeout, completionHandler: completionHandler);
    }

    /// Create and send a DELETE HTTP request
    ///
    /// :param: url The end point's URL
    /// :param: headers Additional headers set for the request
    /// :param: timeout The timeout for the request
    /// :param: completionHandler The response completion closure, it will be executed in the request queue i.e. in a backgound thread
    class func doDelete(url: String, headers: Dictionary<String,String>!, timeout: NSTimeInterval, completionHandler: RequestCompletionHandler) {
        doRequest(url, method: "Delete", payload: nil, headers: headers, timeout: timeout, completionHandler: completionHandler);
    }

    /// Create and send a generic HTTP request
    ///
    /// :param: url The end point's URL
    /// :param: method The HTTP method
    /// :param: payload The data to be POST or PUT is treared as Content-Type: text/plain; charset=utf-8 and it can be override by setting the headers dictionary
    /// :param: headers Additional headers set for the request
    /// :param: timeout The timeout for the request
    /// :param: completionHandler The response completion closure, it will be executed in the request queue i.e. in a backgound thread
    class func doRequest (url: String, method: String, payload: NSData!, headers: Dictionary<String,String>!, timeout: NSTimeInterval,  completionHandler: RequestCompletionHandler) -> Void {
        let queue: NSOperationQueue = NSOperationQueue()
        var req: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.timeoutInterval = timeout

        if !method.isEmpty {
            req.HTTPMethod = method.uppercaseString
        }

        if req.HTTPMethod == "POST" || req.HTTPMethod == "PUT" {

            if payload != nil && payload.length > 0 {
                req.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.addValue("\(payload.length)", forHTTPHeaderField: "Content-Length")
                req.HTTPBody = payload
            } else {
                req.addValue("0", forHTTPHeaderField: "Content-Length")
            }
        }

        if headers != nil {
            for (header,value) in headers {
                req.setValue(value, forHTTPHeaderField: header)
            }
        }

        NSURLConnection.sendAsynchronousRequest(req, queue: queue) { (response, data, error) -> Void in
            if error != nil {
                completionHandler(responseHeaders: [:], data: data, error: error)
            } else {
                /// Check for HTTP error
                let httpResponse = response as! NSHTTPURLResponse
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    completionHandler(responseHeaders: httpResponse.allHeaderFields as? Dictionary<String,String>, data: data, error: error)
                } else {
                    var errorMessage = "The server responded with code \(httpResponse.statusCode)"
                    if  let jsonResponse  = JSON.parse(data: data) as? NSDictionary {
                        errorMessage = jsonResponse["message"]! as! String
                    }

                    let httpError = NSError(domain: "HTTP Request", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey:errorMessage])
                    completionHandler(responseHeaders: httpResponse.allHeaderFields as? Dictionary<String,String> , data: data, error: httpError)
                }
            }
        }
    }
}
