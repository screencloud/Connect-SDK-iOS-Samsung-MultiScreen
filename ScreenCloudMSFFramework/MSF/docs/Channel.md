`<a name="Channel"></a>
#Channel
A Channel is a discreet connection where multiple clients can communicate


**Properties**:

  * [channel.uri](#Channel#uri)
  * [channel.clients](#Channel#clients)
  * [channel.isConnected](#Channel#isConnected)
  * [channel.connectionTimeout](#Channel#connectionTimeout)
  
**Methods Swift**:  
  
  * [channel.connect(attributes, callback)](#Channel#connect)
  * [channel.disconnect()](#Client#disconnect)
  * [channel.disconnect(callback)](#Client#disconnect#callback)
  * [channel.publish(event, message)](#Channel#publish#event#message)
  * [channel.publish(event, message, data)](#Channel#publish#event#message#data)
  * [channel.publish(event, message, target)](#Channel#publish#event#message#target)
  * [channel.publish(event, message, target, data)](#Channel#publish#event#message#target#data)
  * [channel.on()](#channel#on)
  * [channel.off()](#channel#off)

**Methods Objective C**:  

  * [channel.connect(attributes, callback)](#Channel#connect)
  * [channel.disconnect()](#Channel#disconnect)
  * [channel.disconnect(callback)](#Channel#disconnect#callback)
  * [channel.publishWithEvent(message)](#Channel#publish#event#message)
  * [channel.publishWithEvent(message, data)](#Channel#publish#event#message#data)
  * [channel.publishWithEvent(message, target)](#Channel#publish#event#message#target)
  * [channel.publishWithEvent(message, target, data)](#Channel#publish#event#message#target#data)
  * [channel.on()](#channel#on)
  * [channel.off()](#channel#off)

**Events**:

  * [ChannelEvent `enum` for notification](#Channel#ChannelEvent)
      

**Delegate**:

  * [ChannelDelegate `protocol` for delegation](#Channel#ChannelDelegate)


<a name="Channel#uri"></a>
##channel.uri
The uri of the channel ('chat')

**Type**: `String`  

**Read only**  
<a name="Channel#clients"></a>
##channel.clients
The collection of clients currently connected to the channel

**Type**: `[Client]`  

**Read only**
<a name="Channel#isConnected"></a>
##channel.isConnected
The connection status of the channel

**Type**: `Bool`  

**Read only**

<a name="Channel#connectionTimeout"></a>
##channel.connectionTimeout
The timeout for channel transport connection
The connection will be closed if no ping is received within the defined timeout

**Type**: `Bool` 

<a name="Channel#connect"></a>
##channel.connect()
Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a ChannelEvent.Connect notification upon completion.
When a TV application connects to this channel, the onReady method/notification is also fired

<a name="Channel#connect"></a>
##channel.connect(attributes:)
Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a ChannelEvent.Connect notification upon completion.
When a TV application connects to this channel, the onReady method/notification is also fired

**Params**:

- attributes `[String:String]?` - Any attributes you want to associate with the client (ie. ["name":"FooBar"] )

<a name="Channel#connect"></a>
##channel.connect(attributes:completionHandler:)
Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a ChannelEvent.Connect notification upon completion.
When a TV application connects to this channel, the onReady method/notification is also fired

**Params**:

- attributes `[String:String]?` - Any attributes you want to associate with the client (ie. ["name":"FooBar"] )
- completionHandler `(client?:error:) -> Void` - The callback handler
	- client `ChannelClient` The client that is connecting which is yourself
	- error `NSError?` - An error info if connect fails 

<a name="Channel#disconnect"></a>
##channel.disconnect()
Disconnects from the channel. This method will asynchronously call the delegate's onDisconnect and post a ChannelEvent.Disconnect notification upon completion.

<a name="Channel#disconnect#callback"></a>
##channel.disconnect(completionHandler:)
Disconnects from the channel. This method will asynchronously call the delegate's onDisconnect and post a ChannelEvent.Disconnect notification upon completion.

**Params**:

- completionHandler `(client:error:) -> Void` - The callback handler
	- client `ChannelClient` The client that is disconnecting which is yourself
	- error `NSError?` - An error info if disconnect fails 

<a name="Channel#publish#event#message"></a>

##channel.publish(event:message:)
Publish an event containing a text message payload

**Params**:

- event `String` - The name of the event to publish  
- message `AnyObject` - A JSON serializable message object

<a name="Channel#publish#event#message#data"></a>

##channel.publish(event:message:data:)
Publish an event containing a text message and binary payload

**Params**:

- event `String` - The name of the event to publish  
- message `AnyObject` - A JSON serializable message object
- data `NSData` - Any binary data to send with the message

<a name="Channel#publish#event#message#target"></a>

##channel.publish(event:message:target:)
Publish an event with text message payload to one or more targets

**Params**:

- event `String` - The name of the event to publish  
- message `AnyObject` - A JSON serializable message object
- target `AnyObject` - The target recipient(s) of the message.Can be a string client id, a collection of ids or a string MessageTarget (like MessageTarget.All.rawValue)

<a name="Channel#publish#event#message#target#data"></a>

##channel.publish(event:message:data:target:)
Publish an event containing a text message and binary payload to one or more targets

**Params**:

- event `String` - The name of the event to publish  
- message `AnyObject` - A JSON serializable message object
- target `AnyObject` - The target recipient(s) of the message.Can be a string client id, a collection of ids or a string MessageTarget (like MessageTarget.All.rawValue)

<a name="Channel#on"></a>

##channel.on(notificationName:performClosure:)
A convenience method to subscribe for notifications using blocks

**Params**:

- notificationName `String` - The name of the notification
- performClosure `(NSNotification!) -> Void` - The notification block, this block will be executed in the main thread

**Return Value**: - An observer handler for removing/unsubscribing the block from notifications


<a name="Channel#off"></a>

##channel.off(observer:)
A convenience method to unsubscribe for notifications using blocks

**Params**:

- observer `AnyObject` - The observer object to unregister observations



<a name="Channel#ChannelEvent"></a>

##ChannelEvent
This emumeration defines the notification options for a channel, this is an alternative to the ChannelDelegate protocol. 

Use this channel event enumeration in conjunction with the channel.on(...) and channel.off(...) methods in order to receive the notifications in a closure in the main thread

Note:- You can either subscribe to Channel Event Notifications or provide a delegate to get notified of the Channel events. If you implement both the techniques you will be notified twice.

**Constants**:
``` swift
SWIFT
- Connect:          The on connect event
- Disconnect:       The on disconnect event
- ClientConnect:    A client connect event
- ClientDisconnect: A client disconnect event
- Message:          A text message was received
- Data:             A binary data message was received
- Error:            An error happened
- Ready:            The host app is ready to send or receive messages
```
``` js
Objective C


- "ms.channel.connect":          The on connect event
- "ms.channel.disconnect":       The on disconnect event
- "ms.channel.clientConnect":    A client connect event
- "ms.channel.clientDisconnect": A client disconnect event
- "ms.channel.message":          A text message was received
- "ms.channel.data":             A binary data message was received
- "ms.error":                    An error happened
- "ms.channel.ready":            The host app is ready to send or receive messages
```

<a name="Channel#ChannelDelegate"></a>

#ChannelDelegate
The channel delegate protocol defines the event methods available for a channel

Note:- You can either subscribe to Channel Event Notifications or provide a delegate to get notified of the Channel events. If you implement both the techniques you will be notified twice.

**Methods**:  

  * [optional ChannelDelegate.onConnect(error:)](#ChannelDelegate#onConnect)
  * [optional ChannelDelegate.onReady](#ChannelDelegate#onReady)
  * [optional ChannelDelegate.onDisconnect(error:)](#ChannelDelegate#onDisconnect)
  * [optional ChannelDelegate.onMessage(message:)](#ChannelDelegate#onMessage)
  * [optional ChannelDelegate.onData(message: payload:](#ChannelDelegate#onData)
  * [optional ChannelDelegate.onClientConnect(client:)](#ChannelDelegate#onClientConnect)
  * [optional ChannelDelegate.onClientDisconnect(client:)](#ChannelDelegate#onClientDisconnect)
  * [optional ChannelDelegate.onError(error:)](#ChannelDelegate#onError)

<a name="ChannelDelegate#onConnect"></a>

##ChannelDelegate.onConnect(client:error:)
Called when the Channel is connected

**Params**:
- client `ChannelClient` - The client that just connected which is yourself
- error `NSError` - An error info if any

<a name="ChannelDelegate#onReady"></a>

##ChannelDelegate.onReady()
Called when the host app is ready to send or receive messages


<a name="ChannelDelegate#onDisconnect"></a>

##ChannelDelegate.onDisconnect(client?:error:)
Called when the Channel is disconnected

**Params**:
- client `ChannelClient` - The client that just disconnected which is yourself
- error `NSError` - An error info if any


<a name="ChannelDelegate#onMessage"></a>

##ChannelDelegate.onMessage(message:)
Called when the Channel receives a text message

**Params**:

- message `Message` - Text message received


<a name="ChannelDelegate#onData"></a>

##ChannelDelegate.onData(message:payload:)
Called when the Channel receives a binary data message

**Params**:

- message `Message` - Text message received
- payload `AnyObject` - Binary payload data



<a name="ChannelDelegate#onClientConnect"></a>

##ChannelDelegate.onClientConnect(client:)
Called when a client connects to the Channel

**Params**:

- client `ChannelClient` - The Client that just connected to the Channel


<a name="ChannelDelegate#onClientDisconnect"></a>

##ChannelDelegate.onClientDisconnect(client:)
Called when a client disconnects from the Channel

**Params**:

- client `ChannelClient` - The Client that just disconnected from the Channel

<a name="ChannelDelegate#onError"></a>

##ChannelDelegate.onError(error:)
Called when a Channel Error is fired

**Params**:

- error `NSError` - The error



