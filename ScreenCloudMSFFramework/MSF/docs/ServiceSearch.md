<a name="ServiceSearch"></a>
#ServiceSearch
This class searches the local network for compatible multiscreen services

**Properties**:

  * [ServiceSearch.delegate](#ServiceSearch#delegate)
  * [ServiceSearch.services](#ServiceSearch#services)
  * [ServiceSearch.isSearching](#ServiceSearch#isSearching)

**Methods**: 

  * [ServiceSearch.start()](#ServiceSearch#start)
  * [ServiceSearch.stop()](#ServiceSearch#stop)
  * [ServiceSearch.on()](#ServiceSearch#on)
  * [ServiceSearch.off()](#ServiceSearch#off)

**Events Swift**:

  * [MSDidFindService](#ServiceSearch#MSDidFindService)
  * [MSDidRemoveService](#ServiceSearch#MSDidRemoveService)
  * [MSDidStartSeach](#ServiceSearch#MSDidStartSeach)
  * [MSDidStopSeach](#ServiceSearch#MSDidStopSeach)

**Events Objective C**:

  * ["ms.didFindService"](#ServiceSearch#MSDidFindService)
  * ["ms.didRemoveService"](#ServiceSearch#MSDidRemoveService)
  * ["ms.stopSearch"](#ServiceSearch#MSDidStartSeach)
  * ["ms.startSearch"](#ServiceSearch#MSDidStopSeach)

**Delegate**:

  * [ServiceSearchDelegate `protocol` for delegation](#ServiceSearch#ServiceSearchDelegate)    



<a name="ServiceSearch#delegate"></a>
##ServiceSearch.delegate
The delegate that receives search events

**Type**: `ServiceSearchDelegate`  

<a name="ServiceSearch#services"></a>
##ServiceSearch.services
The list of available services

**Type**: `Array of Service`  

<a name="ServiceSearch#isSearching"></a>
##ServiceSearch.isSearching
The search status

**Type**: `bool`


<a name="ServiceSearch#on"></a>

##ServiceSearch.on(notificationName:performClosure:)
A convenience method to subscribe for notifications using blocks

**Params**:

- notificationName `String` - The name of the notification
- performClosure `(NSNotification!) -> Void` - The notification block, this block will be executed in the main thread

<a name="ServiceSearch#off"></a>

##ServiceSearch.off(observer:)
A convenience method to unsubscribe for notifications using blocks

**Params**:

- observer `AnyObject` - The observer object to unregister observations


<a name="ServiceSearch#start"></a>

##ServiceSearch.start()
Starts the search

<a name="ServiceSearch#stop"></a>

##ServiceSearch.stop()
Stops the search

<a name="ServiceSearch#on"></a>

##ServiceSearch.on(notificationName:performClosure:)
A convenience method to suscribe for notifications using blocks

**Params**:

- notificationName `String` - The name of the notification
- performClosure `(NSNotification!) -> Void` - The notification block, this block will be executed in the main thread

**Return Value**: - An observer handler for removing/unsubscribing the block from notifications

<a name="ServiceSearch#off"></a>

##ServiceSearch.off(observer:)
A convenience method to unsuscribe from notifications

**Params**:

- observer `AnyObject` - The observer object to unregister observations



#Events:
The following events are generated as part of the Service Search.

Use these events in conjunction with the ServiceSearch.on(...) and ServiceSearch.off(...) methods in order to receive the notifications in a closure in the main thread

Note:- You can either subscribe to these Event Notifications or provide a delegate to get notified of the Service Search events. If you implement both the techniques you will be notified twice.

In Swift these Events are defined as Enums and in Objective C they are mapped to strings. Please use the string events for Objective C projects.

<a name="ServiceSearch#MSDidFindService"></a>

##MSDidFindService/ms.didFindService
Found a service


<a name="ServiceSearch#MSDidRemoveService"></a>

##MSDidRemoveService/ms.didRemoveService
A service was removed

<a name="ServiceSearch#MSDidStartSeach"></a>

##MSDidStartSeach/ms.startSearch
Started the search for services

<a name="ServiceSearch#MSDidStopSeach"></a>

##MSDidStopSeach/ms.stopSearch
Stopped the search for services



<a name="ServiceSearch#ServiceSearchDelegate"></a>

#ServiceSearchDelegate
This protocol defines the methods for ServiceSearch discovery

Note:- You can either subscribe to these Event Notifications or provide a delegate to get notified of the Service Search events. If you implement both the techniques you will be notified twice.

**Methods**:  

  * [optional ServiceSearchDelegate.onServiceFound(service:)](#ServiceSearchDelegate#onServiceFound)
  * [optional ServiceSearchDelegate.onServiceLost(service:)](#ServiceSearchDelegate#onServiceLost)
  * [optional ServiceSearchDelegate.onStop()](#ServiceSearchDelegate#onStop)
  * [optional ServiceSearchDelegate.onStart()](#ServiceSearchDelegate#onStart)


<a name="ServiceSearchDelegate#onServiceFound"></a>

##ServiceSearchDelegate.onServiceFound(service:)
The ServiceSearch will call this delegate method when a service is found

**Params**:

- service `Service` - The found service

<a name="ServiceSearchDelegate#onServiceLost"></a>

##ServiceSearchDelegate.onServiceLost(service:)
The ServiceSearch will call this delegate method when a service is lost

**Params**:

- service `Service` - The lost service

<a name="ServiceSearchDelegate#onStop"></a>

##ServiceSearchDelegate.onStop()
The ServiceSearch will call this delegate method after stopping the search

<a name="ServiceSearchDelegate#onStart"></a>

##ServiceSearchDelegate.onStart()
The ServiceSearch will call this delegate method after the search has started


