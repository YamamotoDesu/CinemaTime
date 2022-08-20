# CinemaTime

![image](https://user-images.githubusercontent.com/47273077/185731905-1601335e-219b-448c-83b9-252140ac524e.png)


## [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity/wcsession)
> ## WCSession
> The object that initiates communication between a WatchKit extension and its companion iOS app.
> Your iOS app and watchOS app must both create and configure an instance of this class at some point during their execution. When both session objects are active, the two processes can communicate immediately by sending messages back and forth. When only one session is active, the active session may still send updates and transfer files, but those transfers happen opportunistically in the background.

![image](https://user-images.githubusercontent.com/47273077/185734344-672544d9-081a-4d74-8fac-80a97baf6741.png)

## Supporting Communication with Multiple Apple Watches
You do this by implementing the following methods in your session delegate:
* session(_:activationDidCompleteWith:error:)

* sessionDidBecomeInactive(_:)

* sessionDidDeactivate(_:)


> Figure 1 shows the sequence of events that happen when the user switches from one Apple Watch to another. When automatic switching is enabled, only one Apple Watch at a time actually communicates with the iOS app. The Watch app on each watch stays in the active state, but the iOS app moves to the inactive and deactivated states during a switch. 
![image](https://user-images.githubusercontent.com/47273077/185734477-73bdf43f-5d6e-4158-813d-def8a0c16fe2.png)


## Communicating with the Counterpart App
### ■ 1. updateApplicationContext
> Use the updateApplicationContext(_:) method to communicate recent state information to the counterpart. When the counterpart wakes, it can use this information to update its own state. For example, an iOS app that supports Background App Refresh can use part of its background execution time to update the corresponding Watch app. This method overwrites the previous data dictionary, so use this method when your app needs only the most recent data values.
### ■ 2. sendMessage(_:replyHandler:errorHandler:)
> Use the sendMessage(_:replyHandler:errorHandler:) or sendMessageData(_:replyHandler:errorHandler:) method to transfer data to a reachable counterpart. These methods are intended for immediate communication between your iOS app and WatchKit extension. The isReachable property must currently be true for these methods to succeed.
### ■ 3. transferUserInfo(_:)
> Use the transferUserInfo(_:) method to transfer a dictionary of data in the background. The dictionaries you send are queued for delivery to the counterpart and transfers continue when the current app is suspended or terminated.
### ■ 4. transferFile(_:metadata:)
> Use the transferFile(_:metadata:) method to transfer files in the background. Use this method in cases where you want to send more than a dictionary of values. For example, use this method to send images or file-based documents.
### ■ 5. transferCurrentComplicationUserInfo(_:)
> In iOS, use the transferCurrentComplicationUserInfo(_:) method to send data related to your Watch app’s complication. Use of this method counts against your complication’s time budget.



## iPhone
<table>
  <tr>
    <td valign="top"><img width="300" src="https://user-images.githubusercontent.com/47273077/185732020-2db67042-a690-4ba2-a758-9a7fbe8499c1.png"/></td>
    <td valign="top"><img width="300" src="https://user-images.githubusercontent.com/47273077/185732052-892d07f4-bd74-4ab5-a93c-2d015bcf8f62.png"/></td>
    <td valign="top"><img width="300"  src="https://user-images.githubusercontent.com/47273077/185732091-fc82734e-42ef-459f-8b28-e4e18f37bd8f.png"/></td>
  </tr>
</table>

## Apple Watch 

<table>
  <tr>
    <td valign="top"><img width="300" src="https://user-images.githubusercontent.com/47273077/185732155-d77e0c9e-8518-4968-ac2a-a26928c59a2b.png"/></td>
    <td valign="top"><img width="300" src="https://user-images.githubusercontent.com/47273077/185732167-73f94fbd-bf09-445b-9859-7d41d631896f.png"/></td>
    <td valign="top"><img width="300"  src="https://user-images.githubusercontent.com/47273077/185732189-368237c1-e343-4d68-9e83-466aeee6139f.png"/></td>
  </tr>
</table>


### 1. Setting up watch connectivity
Connectivity
```swift
final class Connectivity: NSObject {
  
  static let shared = Connectivity()
  
  private override init() {
    super.init()
    
    // You should only start a session if it is supported.
    #if !os(watchOS)
    guard WCSession.isSupported() else {
      return
    }
    
    #endif
    
    // When you initialize Connextivity, you tell the device to activate the session whitch lets yopu talk to a paired device.
    WCSession.default.activate()
  }
}
```

### 2. Preparing for WCSessionDelegate
```swift
// The WCSessionDelegate protocol extends NSObjectProtocol. That means for Connectivity to be the delegate, it must inherit from NSObject.
final class Connectivity: NSObject {
  
  static let shared = Connectivity()
  
  private override init() {
    super.init()
 ```
 
 ## 3. Impletementing WCSessionDelegate
 ```swift
 // MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
  #if os(iOS) // those mmethods are part of the delegate on iOS
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    // If the person has more than one aplle watch, and they switch,
    // reactivate their session on the new deveice.
    WCSession.default.activate()
    
  }
  #endif
  
}
```
