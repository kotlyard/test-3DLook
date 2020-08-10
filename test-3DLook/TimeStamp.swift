//
//  TimeStamp.swift
//  test-3DLook
//
//  Created by Денис Котляр on 10.08.2020.
//  Copyright © 2020 Денис Котляр. All rights reserved.
//

import Foundation

struct TimeStamp {
  let stamp: TimeInterval = 0
  let note: String = ""
}


final class TimerService {
  static let shared = TimerService()
  private init() {}
}
