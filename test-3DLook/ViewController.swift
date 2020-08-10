//
//  ViewController.swift
//  test-3DLook
//
//  Created by Денис Котляр on 10.08.2020.
//  Copyright © 2020 Денис Котляр. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cellNib = UINib(nibName: "TimeStampTableViewCell", bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: "TimeStampTableViewCell")
    
    createGestureRecognizers()
  }
  
  private func createGestureRecognizers() {
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    
    singleTap.numberOfTapsRequired = 1
    doubleTap.numberOfTapsRequired = 2
    
    singleTap.require(toFail: doubleTap)
  
    headerView.addGestureRecognizer(singleTap)
    headerView.addGestureRecognizer(doubleTap)
  }

  @objc func doubleTapped() {
    stop()
    tableView.backgroundColor = .white
  }

  @IBAction func singleTapped() {
    tableView.backgroundColor = .black
    
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()

    switch state {
      case .initial,
           .paused:
        start()
      case .running:
        pause()
    }
  }
  
  private func start() {
    state = .running
    startTime = Date().timeIntervalSinceReferenceDate - time

    createTimer()
  }

  private func pause() {
    state = .paused

    timer?.invalidate()
  }
  
  private func stop() {
    pause()
    reset()
  }

  private func reset() {
    state = .initial

    startTime = 0
    time = 0
  }

  // MARK: - Timer stuff
  var timer: Timer?

  var state: TimerState = .initial
  var timeStamps: [TimeStamp] = []
  

  private var timeInterval = 0.1

  @IBOutlet weak var minutesLabel: UILabel!
  @IBOutlet weak var secondsLabel: UILabel!
  @IBOutlet weak var miliSecondsLabel: UILabel!
  
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

  
  var startTime: TimeInterval!

  /// Time passed since start time
  var time: TimeInterval = 0 {
    didSet {
      updateLabels()
    }
  }

  /// Returns strring representing given integer with 2 leading zeroes if possible
  private func formatTimeInterval(timeUnits: Int) -> String {
    String(format: "%02d", timeUnits)
  }

  /// Updates time labels with time variable in appropriate format
  private func updateLabels() {
    minutesLabel.text =  formatTimeInterval(timeUnits: Int(time / 3600 * 100)) + " : "
    secondsLabel.text = formatTimeInterval(timeUnits: Int(time.truncatingRemainder(dividingBy: 60))) + " :"
    miliSecondsLabel.text = formatTimeInterval(timeUnits: Int(time.truncatingRemainder(dividingBy: 1) * 10))
  }


}

// MARK: - TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TimeStampTableViewCell", for: indexPath) as! TimeStampTableViewCell
    
    
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.height / 6
  }
  
}
