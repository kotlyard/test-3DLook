//
//  TimerService.swift
//  test-3DLook
//
//  Created by Денис Котляр on 10.08.2020.
//  Copyright © 2020 Денис Котляр. All rights reserved.
//

import Foundation


protocol TimerServiceDelegate: class {
  func timeUpdated(_ time: TimeInterval)
}

class TimerService {
  weak var delegate: TimerServiceDelegate?
  
  enum State {
    case initial
    case running
    case paused
  }
  
  func startTimer() {
    state = .running
    startTime = Date().timeIntervalSinceReferenceDate - time
    
    createTimer()
  }
  
  func pauseTimer() {
    state = .paused
    
    timer?.invalidate()
  }
  
  func stopTimer() {
    pauseTimer()
    
  }
  
  func resetTimer() {
    state = .initial
    
    startTime = 0
    time = 0
  }
  
  // MARK: - Timer stuff
  var timer: Timer?
  
  var state: State = .initial
  
  @UserDefaultsBacked(key: "timeStamps", defaultValue: [])
  var timeStamps: [TimeStamp]
  
  
  private var timeInterval = 0.1
  
  
  var startTime: TimeInterval!
  
  /// Time passed since start time
  var time: TimeInterval = 0 {
    didSet {
      delegate?.timeUpdated(time)
    }
  }
  
  /// Returns strring representing given integer with 2 leading zeroes if possible
  func formatTimeInterval(timeUnits: Int) -> String {
    String(format: "%02d", timeUnits)
  }
  
  
  private func createTimer() {
    timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                 target: self,
                                 selector: #selector(updateTime),
                                 userInfo: nil,
                                 repeats: true)
  }
  
  @objc private func updateTime() {
    time = Date().timeIntervalSinceReferenceDate - startTime
  }
  
}
