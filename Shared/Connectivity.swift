//
//  Connectivity.swift
//  CinemaTime
//
//  Created by 山本響 on 2022/08/20.
//

import Foundation
import WatchConnectivity

final class Connectivity {
  
  static let shared = Connectivity()
  
  private init() {
    
    #if !os(watchOS)
    guard WCSession.isSupported() else {
      return
    }
    
    #endif
    
    WCSession.default.activate()
  }
}
