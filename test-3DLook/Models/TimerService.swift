//
//  TimerService.swift
//  test-3DLook
//
//  Created by Денис Котляр on 10.08.2020.
//  Copyright © 2020 Денис Котляр. All rights reserved.
//

import UIKit

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

  init() {
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(applicationWillTerminate),
                   name: UIApplication.willTerminateNotification,
                   object: nil)
  }
  
  @objc private func applicationWillTerminate() {
    if state == .running {
      // Saving termination time
      let currerntAbsoluteTime = CFAbsoluteTimeGetCurrent()

      UserDefaults.standard.set(currerntAbsoluteTime, forKey: "terminationAbsoluteTime")
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func continueIfNeeded() {
    // Calculate new value if timer should have run all the time
    if UserDefaults.standard.bool(forKey: "wasRunning") {
      let timePassed = UserDefaults.standard.double(forKey: "terminationAbsoluteTime")
      
      time += CFAbsoluteTimeGetCurrent() - timePassed
      
      // Continue counting
      startTimer()
    }
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
  
  var state: State = .initial {
    didSet {
      UserDefaults.standard.set(state == .running, forKey: "wasRunning")
    }
  }
  
  /// Array of Timestamps user made by stopping timer
  @UserDefaultsBacked(key: "timeStamps", defaultValue: [])
  var timeStamps: [TimeStamp]
  
  
  /// Time interval for firing the timer
  private var timeInterval = 0.1
  
  var startTime: TimeInterval!
  
  /// Time passed since start time
  @UserDefaultsBacked(key: "time", defaultValue: 0)
  var time: TimeInterval {
    didSet {
      delegate?.timeUpdated(time)
    }
  }
  
  /// Returns string representing given integer with 2 leading zeroes if possible
  func formatTimeInterval(timeUnits: Int) -> String {
    String(format: "%02d", timeUnits)
  }
  
  private func createTimer() {
    timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                 target: self,
                                 selector: #selector(updateTime),
                                 userInfo: nil,
                                 repeats: true)
    RunLoop.main.add(timer!, forMode: .common)
  }
  
  @objc private func updateTime() {
    time = Date().timeIntervalSinceReferenceDate - startTime
  }
  
}
