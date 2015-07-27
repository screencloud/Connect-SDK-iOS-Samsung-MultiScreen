<a name="Application"></a>
#Application
An Application represents an application on the TV device.
Use this class to control various aspects of the application such as launching the app or getting information

**Extends**: `Channel`

**Methods**:
  
  * [application.getInfo(callback)](#Application#getInfo)
  * [application.start(callback)](#Application#start)
  * [application.stop(callback)](#Application#stop)
  * [application.install(callback)](#Application#install)
  * [application.disconnect()](#Application#disconnect)
  * [application.disconnect(leaveHostRunning)](#Application#disconnect#leaveHostRunning)
  * [application.disconnect(callback)](#Application#disconnect#callback)

<a name="Application#getInfo"></a>
##application.getInfo(completionHandler:)
Retrieves information about the Application on the TV

**Params**:

- completionHandler `(info:error:) -> Void` - The callback handler
	- info `[String:AnyObject]?` - The application info
	- error `NSError?` - An error info if getInfo fails

**Discussion**:

The returned dictionary contains the following keys:

- running `Bool` - true if it is running otherwise false
- version `String` - the application version
- id `String` - the application id
- name `String` - the application name

<a name="Application#start"></a>
##application.start(completionHandler:)
Launches the application on the remote device, if the application is already running it returns success = true.
If the startOnConnect is set to false this method needs to be called in order to start the application

**Params**:

- completionHandler `(success:error:) -> Void` - The callback handler
	- success `Bool` - True if the app is started
	- error `NSError?` - An error info if start fails 

**Discussion**:

The application will trigger a ready event when it is ready to receive messages. This event is generally the starting point for your application logic

**Example**:

```swift
	app.delegate = self
	app.startOnConnect = false
	app.connect()
	...
	app?.start({ (success, error) -> Void in

    })
    ...
    // onReady Channel Delegate Method
    func onReady() {
    	// Start your application logic
        app.publish(event: "say", message: "Hello World")
    }

```

<a name="Application#stop"></a>
##application.stop(completionHandler:)
Stops the application on the TV

**Params**:

- completionHandler `(success:error:) -> Void` - The callback handler
	- success `Bool` - True if the app was stopped
	- error `NSError?` - An error info if stop fails 

<a name="Application#install"></a>
##application.install(completionHandler:)
Starts the application install on the TV, this method will fail for cloud applications

**Params**:

- completionHandler `(success:error:) -> Void` - The callback handler
	- success `Bool` - True if the app was stopped
	- error `NSError?` - An error info if stop fails 


<a name="Application#disconnect"></a>
##application.disconnect()
Disconnects your client with the host TV app and terminates the host app if you are the last client disconnecting

 
<a name="Application#disconnect#leaveHostRunning"></a>
##application.disconnect(leaveHostRunning:)
Disconnects your client with the host TV app

**Params**:

- leaveHostRunning `Bool` - True leaves the TV app running False stops the TV app if yours is the last client 


<a name="Application#disconnect#callback"></a>
##application.disconnect(leaveHostRunning: completionHandler:)
Disconnects your client with the host TV app

**Params**:

- leaveHostRunning `Bool` - True leaves the TV app running False stops the TV app if yours is the last client
- completionHandler `(client:error:) -> Void` - The callback handler
    - client `ChannelClient` - The client that is disconnecting which is yourself
    - error `NSError?` - An error info if disconnect fails 

