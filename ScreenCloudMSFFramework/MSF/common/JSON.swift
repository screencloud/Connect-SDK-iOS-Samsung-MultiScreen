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

public class JSON {

    public class func parse(#jsonString: String) -> AnyObject? {
        let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        return parse(data:data)
    }

    public class func parse(#data: NSData) -> AnyObject? {
        var e: NSError?
        if let jsonObj: AnyObject = NSJSONSerialization.JSONObjectWithData( data, options: NSJSONReadingOptions(0), error: &e) {
            return jsonObj
        } else {
            return NSString(data: data, encoding: NSUTF8StringEncoding)!
        }
    }

    public class func stringify(jsonObject: AnyObject, prettyPrint: Bool = false) -> String? {
        var error: NSError?
        let jsonData: NSData? = NSJSONSerialization.dataWithJSONObject(jsonObject,
            options:  (prettyPrint ? .PrettyPrinted : NSJSONWritingOptions(0)),
            error:&error)
        if (jsonData == nil) {
            return nil
        } else {
            return  NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as String?
        }
    }

    public class func jsonDataForObject(jsonObj: AnyObject) -> NSData? {
        var e: NSError?
        if let jsonData = NSJSONSerialization.dataWithJSONObject(jsonObj,options: NSJSONWritingOptions(0), error: &e) {
            return jsonData
        }
        return nil
    }
    
}