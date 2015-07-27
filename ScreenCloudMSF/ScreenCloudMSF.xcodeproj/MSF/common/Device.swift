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

@objc
public class Device {
    private var deviceInfo: [String:String]
    
    public var duid: String {
        return deviceInfo["duid"]!
    }
    
    public var model: String {
        return deviceInfo["model"]!
    }
    
    public var description: String {
        return deviceInfo["description"]!
    }
    
    public var networkType: String {
        return deviceInfo["networkType"]!
    }

    public var ssid: String {
        return deviceInfo["ssid"]!
    }

    public var ip: String {
        return deviceInfo["ip"]!
    }
    
    public var firmwareVersion: String {
        return deviceInfo["firmwareVersion"]!
    }

    public var name: String {
        return deviceInfo["name"]!
    }

    public var id: String {
        return deviceInfo["id"]!
    }

    public var udn: String {
        return deviceInfo["udn"]!
    }

    public var resolution: String {
        return deviceInfo["resolution"]!
    }
    
    public var countryCode: String {
        return deviceInfo["countryCode"]!
    }
    
    internal init (info: Dictionary<String,String>) {
        deviceInfo = info
    }
    
}