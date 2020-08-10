//
//  TimeStamp.swift
//  test-3DLook
//
//  Created by Денис Котляр on 10.08.2020.
//  Copyright © 2020 Денис Котляр. All rights reserved.
//

import Foundation


enum TimerState {
  case initial
  case running
  case paused
}

struct TimeStamp {
  let stamp: TimeInterval = 0
  let note: String = ""
}

///
@propertyWrapper struct UserDefaultsBacked<Value> {
  let key: String
  let defaultValue: Value
  var storage: UserDefaults = .standard
  
  var wrappedValue: Value {
    get {
      let value = storage.value(forKey: key) as? Value
      return value ?? defaultValue
    }
    set {
      storage.setValue(newValue, forKey: key)
    }
  }
}
