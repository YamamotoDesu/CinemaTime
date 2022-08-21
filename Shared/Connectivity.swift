//
//  Connectivity.swift
//  CinemaTime
//
//  Created by 山本響 on 2022/08/20.
//

import Foundation
import WatchConnectivity

final class Connectivity: NSObject, ObservableObject {
  @Published var puchaseIds: [Int] = []
  
  static let shared = Connectivity()
  
  private override init() {
    super.init()
    
    #if !os(watchOS)
    guard WCSession.isSupported() else {
      return
    }
    
    #endif
    
    WCSession.default.delegate = self
    
    WCSession.default.activate()
  
  }
  
  public func send(movieIds: [Int],
                   delivery: Delivery,
                   replyHandler: (([String: Any]) -> Void)? = nil,
                   errorHandler: ((Error) -> Void)? = nil
  ) {
    guard WCSession.default.activationState == .activated else {
      return
    }
    
    #if os(watchOS)
    guard WCSession.default.isCompanionAppInstalled else { // THe Apple Watch checks if the app is on the phone.
      return
    }
    #else
    guard WCSession.default.isWatchAppInstalled else { // The iOS deveice checks if the app is on the Apple Watch.
      return
    }
    #endif
    
    let userInfo: [String: [Int]] = [
      ConnectivityUserInfoKey.purchased.rawValue: movieIds
    ]
    
    //WCSession.default.transferUserInfo(userInfo)
    switch delivery {
    case .failable:
      WCSession.default.sendMessage(
        userInfo,
        replyHandler: optionalMainQueueDispach(handler: replyHandler),
        errorHandler: optionalMainQueueDispach(handler: errorHandler)
      )
      break
    case .guranteed:
      WCSession.default.transferUserInfo(userInfo)
    case .heighPriority:
      do {
        try WCSession.default.updateApplicationContext(userInfo)
      } catch {
        errorHandler?(error)
      }
    }
  }
  
  typealias OptionalHandler<T> = ((T) -> Void)?
  
  private func optionalMainQueueDispach<T>(
    handler: OptionalHandler<T>
  ) -> OptionalHandler<T> {
    guard let handler = handler else {
      return nil
    }
    
    return { item in
      DispatchQueue.main.async {
        handler(item)
      }
    }
  }

}

// MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
  #if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    // If the person has more than one aplle watch, and they switch,
    // reactivate their session on the new deveice.
    WCSession.default.activate()
    
  }
  #endif
  
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    update(from: userInfo)
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    update(from: applicationContext)
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    update(from: message)
    
    let key = ConnectivityUserInfoKey.verified.rawValue
    replyHandler([key: true])
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    update(from: message)
  }
  
  private func update(from dictionary: [String: Any]) {
    let key = ConnectivityUserInfoKey.purchased.rawValue
    guard let ids = dictionary[key] as? [Int] else {
      return
      
    }
    
    self.puchaseIds = ids
  }
  
}
