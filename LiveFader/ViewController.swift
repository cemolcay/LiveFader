//
//  ViewController.swift
//  LiveFader
//
//  Created by cem.olcay on 11/02/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var verticalBottomFader: LiveFaderView?
  @IBOutlet weak var verticalMiddleFader: LiveFaderView?
  @IBOutlet weak var horizontalBottomFader: LiveFaderView?
  @IBOutlet weak var horizontalMiddleFader: LiveFaderView?

  override func viewDidLoad() {
    super.viewDidLoad()
    verticalBottomFader?.direction = .vertical
    verticalBottomFader?.style = .fromBottom
    verticalBottomFader?.setNeedsLayout()
    verticalMiddleFader?.direction = .vertical
    verticalMiddleFader?.style = .fromMiddle
    verticalMiddleFader?.setNeedsLayout()
    horizontalBottomFader?.direction = .horizontal
    horizontalBottomFader?.style = .fromBottom
    horizontalBottomFader?.setNeedsLayout()
    horizontalMiddleFader?.direction = .horizontal
    horizontalMiddleFader?.style = .fromMiddle
    horizontalMiddleFader?.setNeedsLayout()
  }

  @IBAction func faderValueDidChange(sender: LiveFaderView) {
    print("\(sender) \(sender.value)")
  }
}

class FaderScrollViewController: UIViewController {
  @IBOutlet weak var faderScrollView: LiveFaderScrollView?

  @IBAction func faderScrollerSwitchValueDidChange(sender: UISwitch) {
    faderScrollView?.isFaderPanningEnabled = sender.isOn
  }
}
