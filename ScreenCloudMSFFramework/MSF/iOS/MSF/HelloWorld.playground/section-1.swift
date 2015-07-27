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

import UIKit
import MSF
import XCPlayground


//class HelloWorld: ServiceSearchDelegate {
//
//    let channelURI = "com.samsung.multiscreen.helloworld"
//    let appURL = "http://prod-multiscreen-examples.s3-website-us-west-1.amazonaws.com/examples/helloworld/tv/"
//    var app: Application!
//    var search = Service.search()
//    var service: Service? = nil
//
//    init () {
//        search.delegate = self
//        search.start()
//    }
//
//    func selecService(service: Service) {
//        app = service.createApplication(NSURL(string: appURL)!, channelURI: channelURI )
//        app.connect(["name":UIDevice.currentDevice().name]) { [unowned self ] (channel: Channel, error: NSError?) in
//            if error != nil {
//                println(error?.localizedDescription)
//            } else {
//                println("TV App is Ready")
//                self.app.publish(event: "say", message: "Hello TV...")
//            }
//        }
//    }
//
//    //MARK: --  ServiceSearchDelegate --
//
//    func onServiceFound(service: MSF.Service) {
//        println(service.name)
//        //Select the first found service
//        if self.service == nil && service.name == "aljopBox" {
//            self.service = service
//            search.stop()
//            self.selecService(self.service!)
//        }
//    }
//
//}

class HelloWorld: ServiceSearchDelegate {

    let channelURI = "com.samsung.multiscreen.chatdemo"
    let appId = "ChatDemo"
    var app: Application!
    var search = Service.search()
    var service: Service? = nil

    init () {
        search.delegate = self
        search.start()
    }

    func selecService(service: Service) {
        app = service.createApplication(appId, channelURI: channelURI, args: nil )
//        app.install { (success, error) -> Void in
//            println(error)
//        } 
        app.connect(["name":UIDevice.currentDevice().name]) { [unowned self ] (channel: Channel, error: NSError?) in
            if error != nil {
                println(error?.localizedDescription)
            } else {
                println("TV App is Ready")
                self.app.publish(event: "say", message: "Hello TV...")
            }
        }
    }

    //MARK: --  ServiceSearchDelegate --

    func onServiceFound(service: MSF.Service) {

        //Select the first found service
        if self.service == nil && service.name == "aljopBox" {
            self.service = service
            //search.stop()
            self.selecService(self.service!)
        } else {
            println("ignoring \(service.name)")
        }
    }
    
}

let helloWorld = HelloWorld()

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
