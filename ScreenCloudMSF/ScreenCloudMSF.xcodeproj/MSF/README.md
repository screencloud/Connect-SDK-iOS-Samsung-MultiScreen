# MultiScreen SDK iOS/macOS API #

This api is the iOS component of the MultiScreen SDK.

The Samsung MultiScreen API allows you to connect mobile devices and SmartTVs. Create compelling MultiScreen applications that extend your mobile application experiences to the Samsung SmartTVs. The API provides developers to provide multiscreen experiences for Games, Media Sharing, Social Collaboration, and more.

The swift API is used for mobile applications, to connect to SmartTV applications. 


For more information about the MultiScreen SDK, see:[ http://multiscreen.samsung.com](http://multiscreen.samsung.com)

#### Jump to API Docs

- [Service](docs/Service.md "Service")
- [ServiceSearch](docs/ServiceSearch.md "ServiceSearch")
- [Application](docs/Application.md "Application")
- [Channel](docs/Channel.md "Channel")
- [ChannelClient](docs/ChannelClient.md "ChannelClient")
- [Message](docs/Message.md "Message")

## Include in your iOS project ##

1. Add the MSF project reference to your project:
    
    - Open a terminal and go to your project folder

    cd to/your/project/path/

    - Clone the MSF project

    git submodule add https://github.com/MultiScreenSDK/swift-msf-api.git MSF/.

    git submodule update --init --recursive

    git submodule foreach git pull origin master

2. Add the iOS MSF.xcodeproj to the project as a dependency (either drag and drop or add files to project).

3. Add the MSF framework as an embedded binary (by going to project settings > your target > general > embedded binaries and add the MSF framework)

4. Ensure that the "Target Dependency" contains the MSF framework dependency. (by going to project settings > your target > Build Phases > Target Dependencies and add the MSF framework)

NOTE: For Objective-C based projects add "@import MSF;" to files that interface with MultiScreen Framework."

## API Usage
Overview (Discover, Connect, Communicate)

## Discover ##
In order to start or join a MultiScreen experience, a mobile device must be able to discover a compatible TV or services.

You can discover a compatible Samsung SmartTV on your network using the [ServiceSearch](docs/ServiceSearch.md "ServiceSearch") class. The general workflow is as follows:

1. Start the Discovery Process
1. Listen for notifications indicating services added/removed or by implementing the ServiceSearchDelegate protocol
1. Stop the Discovery Process

Generally while the discovery process is running, you should display a list of discovered services to your user, and allow them to select one to work with. While searching you can get a list of the last discovered services.

Since the search process would drain the battery, stop the search when it is no longer required (like after the user selects a TV).

Example:

```swift
let search =  Service.search()

init () {
    search.delegate = self
    search.start()
}

func onServiceFound(service: Service) {
    // Update your UI by using the search.services array or modify your own service list
}

func onServiceLost(service: Service) {
    // Update your UI by using the search.services array or modify your own service list
}

...

//After the service is selected
search.stop()

```
Alternatively you can suscribe for notifications and unsubscribe after connect to a application or a channel

Example:

```swift
var didFindServiceObserver: AnyObject? = nil

var didRemoveServiceObserver: AnyObject? = nil

func listenForNotifications() {
    didFindServiceObserver = NSNotificationCenter.defaultCenter().addObserverForName(MSDidFindService, object: serviceDiscovery, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
        let service = notification.userInfo["service"] as? Service
    }

    didRemoveServiceObserver = NSNotificationCenter.defaultCenter().addObserverForName(MSDidRemoveService, object: serviceDiscovery, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
        let service = notification.userInfo["service"] as? Service
    }
}
```

Note: If you know the previously connected TV information you can get the service by id as shown below:

```swift
Service.getById("YOUR_TV_SERVICE_ID", completionHandler: {(service, error) -> Void in
    if service != nil {
        //found the tv service
    } else {
        //Use the regular discovery as shown above
    }
})
```

## Connect ##
Once a compatible SmartTV is discovered, you can launch your application on the TV from the mobile device. The application management APIs allow launching, stopping, installing, or retrieving information about an application. Client devices can launch both installed applications or cloud web applications. Here is a quick example.
```swift
// this launches an installed app
let appId = "my-samsung-installed-app-id"
var app = service.createApplication(appId,"com.samsung.multiscreen.helloworld")!

// this launches a cloud app
// let appURL = NSURL(string: "http://yourappurl")!
// var app = service.createApplication(appURL,"com.samsung.multiscreen.helloworld")!

// Subscribe for notifications or set the delegate for events
app.connect()

```

## Communicate ##
Now that the application is launched and connected, lets get the devices talking. You can use channels to provide communication between the devices. The Application class extends Channel, so in the example below we will continue with the application instance we created earlier. Channels provide notifications when someone connects, disconnects, and publishes a message. 

###Note: ####
It is important to wait for the ChannelEvent.Ready before start communicating with the TV application.

```swift

// for cloud applications use
var appURL = NSURL(string: "http://prod-multiscreen-examples.s3-website-us-west-1.amazonaws.com/examples/helloworld/tv/")!
var app = service.createApplication(appURL,"com.samsung.multiscreen.helloworld")!

// app.on is a helper method that encapsulates the NSNotificationCenter calls
var connectObserver = app.on(ChannelEvent.Connect.rawValue) { (notification) -> Void in
    println("Waiting for the TV...")
}

// This lets the client App know that it is ready to communicate with the TV App
var readyObserver = app.on(ChannelEvent.Ready.rawValue) { (notification) -> Void in
    println("The TV App is ready")
    app.publish(event: "say", message: "Hello World")
}

var sayObserver  = app.on("say") { (notification) -> Void in
    if let stringMessage = notification.userInfo["message"] as String {
        println(stringMessage)
    }
}

app.connect()

...

//publishing examples

// Send a binary data to all clients including the host
var image = UIImage ...
var imageData = UIImageJPEGRepresentation(image,0.6)
app.publish(event: "showPhoto", message: ["imageType": "JPEG", "rotate":45], data: imageData, target: MessageTarget.All.rawValue)

// Send a text message to the host
app.publish(event: "say", message: "Hello Host", target: MessageTarget.Host.rawValue)

// Broadcast a text message
app.publish(event: "say", message: "Hello All of you", target: MessageTarget.Broadcast.rawValue)

// Send a text message to a client
app.publish(event: "say", message: "Hello Client 1", target: app.clients[0].id)

// Teardown
app.disconnect()
app.off(connectObserver)
app.off(readyObserver)
app.off(sayObserver)

```

## Disconnect ##
When you are done with the application, the app should close the connection with the TV and if this is the last connected client, the TV aplication will be terminated.

```swift
app.disconnect()
```


## App Managment ##

  * [start](docs/Application.md#Application#start)
  * [stop](docs/Application.md#Application#stop)
  * [install](docs/Application.md#Application#install)
  * [disconnect](docs/Application.md#Application#disconnect)

## License ##

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
