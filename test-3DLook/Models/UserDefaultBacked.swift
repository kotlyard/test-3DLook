//
//  UserDefaultBacked.swift
//  test-3DLook
//
//  Created by Денис Котляр on 10.08.2020.
//  Copyright © 2020 Денис Котляр. All rights reserved.
//

import Foundation

@propertyWrapper struct UserDefaultsBacked<Value: Codable> {
  let key: String
  let defaultValue: Value
  var storage: UserDefaults = .standard
  
  var wrappedValue: Value {
    get {
      if let data = storage.object(forKey: key) as? Data {
        let value = try? JSONDecoder().decode(Value.self, from: data)
        return value ?? defaultValue
      }
      return defaultValue
    }
    
    set {
      let encoder = JSONEncoder()
      if let encoded = try? encoder.encode(newValue) {
        storage.set(encoded, forKey: key)
      }
    }
  }
  
}
