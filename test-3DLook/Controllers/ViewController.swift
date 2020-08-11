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
  
  @IBOutlet weak var minutesLabel: UILabel!
  @IBOutlet weak var secondsLabel: UILabel!
  @IBOutlet weak var miliSecondsLabel: UILabel!

  /// The service that handles all timer stuff
  let timerService = TimerService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cellNib = UINib(nibName: "TimeStampTableViewCell", bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: "TimeStampTableViewCell")
    
    createGestureRecognizers()

    timerService.delegate = self
    
    updateLabels(with: timerService.time)
    timerService.continueIfNeeded()
  }

  // MARK: - Gestures
  private func createGestureRecognizers() {
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    
    singleTap.numberOfTapsRequired = 1
    doubleTap.numberOfTapsRequired = 2
    
    singleTap.require(toFail: doubleTap)

    headerView.addGestureRecognizer(singleTap)
    headerView.addGestureRecognizer(doubleTap)
  }
  
  @objc private func singleTapped() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
    
    switch timerService.state {
      case .initial, .paused:
        timerService.startTimer()
      case .running:
        timerService.pauseTimer()
    }
  }
  
  @objc private func doubleTapped() {
    timerService.stopTimer()
    
    showAlert()
  }
  
  // MARK: - Alert
  private func showAlert() {
    let alertVC = UIAlertController(title: "Enter a note to your timestamp",
                                    message: nil,
                                    preferredStyle: .alert)
    alertVC.addTextField { (textField) in
      textField.placeholder = "Best time ever"
    }
    
    let action = UIAlertAction(title: "OK", style: .default) { (_) in
      let timeStampString = self.minutesLabel.text! + self.secondsLabel.text! + self.miliSecondsLabel.text!
      
      let timeStamp = TimeStamp(stamp: timeStampString,
                                note: alertVC.textFields?.first?.text ?? "")
      
      self.timerService.timeStamps.append(timeStamp)
      
      self.timerService.resetTimer()
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
    
    alertVC.addAction(action)
    show(alertVC, sender: nil)
  }
  
  
  /// Updates time labels with time variable in appropriate format
  private func updateLabels(with time: TimeInterval) {
    minutesLabel.text =  timerService.formatTimeInterval(timeUnits: Int(timerService.time / 60)) + " :"
    secondsLabel.text = timerService.formatTimeInterval(timeUnits: Int(timerService.time.truncatingRemainder(dividingBy: 60))) + " :"
    miliSecondsLabel.text = "\(Int(timerService.time.truncatingRemainder(dividingBy: 1) * 10))0"
  }
  
}

// MARK: - TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    timerService.timeStamps.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TimeStampTableViewCell", for: indexPath) as! TimeStampTableViewCell
    
    cell.noteLabel.text = timerService.timeStamps[indexPath.row].note
    cell.timeStampLabel.text = timerService.timeStamps[indexPath.row].stamp
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.height / 6
  }
  
}

// MARK: - TimerServiceDelegate
extension ViewController: TimerServiceDelegate {
  func timeUpdated(_ time: TimeInterval) {
    updateLabels(with: time)
  }
}
