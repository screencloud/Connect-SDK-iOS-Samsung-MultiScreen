<a name="Service"></a>
#Service
A Service instance represents the multiscreen service root on the remote device
Use the class to control top level services of the device

**Properties**:

  * [service.id](#Service#id)
  * [service.name](#Service#name)
  * [service.version](#Service#version)
  * [service.type](#Service#type)
  * [service.uri](#Service#uri)


**Methods**:

  * [service.getDeviceInfo](#Service#getDeviceInfo)
  * [service.createApplication](#Service#createApplication)
  * [service.createChannel](#Service#createChannel)

**Class Methods**:

  * [service.search](#Service#search)
  * [service.getById](#Service#getById)
  * [service.getByURL](#Service#getByURL)


<a name="Service#id"></a>
##service.id
The id of the service

**Type**: `String`  
**Read only**
<a name="Service#name"></a>
##service.name
The name of the service (Living Room TV)

**Type**: `String`  
**Read only**
<a name="Service#version"></a>
##service.version
The version of the service (x.x.x)

**Type**: `String`  
**Read only**
<a name="Service#type"></a>
##service.type
The type of the service (Samsung SmartTV)

**Type**: `String`  
**Read only**
<a name="Service#uri"></a>
##service.uri
The uri of the service (http://<ip>:<port>/api/v2/)

**Type**: `String`  
**Read only**

<a name="Service#getDeviceInfo"></a>
##getDeviceInfo(timeout:completionHandler:)
This asynchronously method retrieves a dictionary of additional information about the device the service is running on

**Params**:
- timeout `int` - timeout
- completionHandler `(deviceInfo: error:) -> Void` - A block to handle the response dictionary
	- deviceInfo `[String:String]?` - The device info dictionary
	- error `NSError?` - An error info if getDeviceInfo failed
	
**Return Value**: `Void`  

<a name="Service#createApplication"></a>
##createApplication(id:channelURI:args:)
Creates an application instance belonging to that service

**Params**:

- id `AnyObject` - The id of the application
	- For an installed application this is the string id as provided by Samsung, If your TV app is still in development, you can use the folder name of your app as the id. Once the TV app has been released into Samsung Apps, you must use the supplied app id.
	- For a cloud application this is the application's URL

- channelURI `String` - The uri of the Channel ("com.samsung.multiscreen.helloworld")

- args `Dictionary` A dictionary of command line aruguments to be passed to the Host TV App

**Return Value**: `Application?` 

<a name="Service#createChannel"></a>
##createChannel(uri:)
Creates a channel instance belonging to that service ("mychannel")

createChannel(channelURI:)

**Params**:

- channelURI `String` - The uri of the Channel ("com.samsung.multiscreen.helloworld")

**Return Value**: `Channel` 

<a name="Service#search"></a>
##search()
Creates a service search object

**Return Value**: `ServiceSearch`

<a name="Service#getByURI"></a>
##getByURI(uri:completionHandler:)
This asynchronous method retrieves a service instance given a service URI

**Params**:

- uri `String` - The uri of the service
- completionHandler `(service:error:) -> Void` -
	- service `Service?` - The service instance
	- error `NSError?` - An error info if getByURI fails

**Return Value**: `Void`

<a name="Service#getById"></a>
##getById(id:completionHandler:)
This asynchronous method retrieves a service instance given a service id

**Params**:

- id `String` - The id of the service
- completionHandler `(service:error:) -> Void` -
	- service `Service?` - The service instance
	- error `NSError?` - An error info if getById fails

**Return Value**: `Void`
 