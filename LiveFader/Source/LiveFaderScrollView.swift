//
//  LiveFaderScrollView.swift
//  LiveFader
//
//  Created by cem.olcay on 12/02/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit

/// Lets you control multiple faders in a scroll view with a single pan gesture.
public class LiveFaderScrollView: UIScrollView, UIGestureRecognizerDelegate {
  /// Setter for multiple fader editing with a single pan gesture.
  public var isFaderPanningEnabled = false { didSet { faderPanningStateDidChange() }}
  /// The single pan gesture that controls the every fader in the scroll view.
  private var faderPanGestureRecognizer = UIPanGestureRecognizer()
  /// Fader view cache for the current faders in the scroll view.
  private var faderViews = [LiveFaderView]()

  // MARK: Init

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  /// Initializes the pan gesture.
  private func commonInit() {
    faderPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleFaderPanning(pan:)))
    faderPanGestureRecognizer.isEnabled = false
    addGestureRecognizer(faderPanGestureRecognizer)
  }

  // MARK: Lifecycle

  /// Setups the multiple fader editing mode.
  private func faderPanningStateDidChange() {
    if isFaderPanningEnabled {
      isScrollEnabled = false
      faderPanGestureRecognizer.isEnabled = true
      faderViews = getAllFaderViews()
      faderViews.forEach({ $0.panGestureRecognizer.isEnabled = false })
    } else {
      isScrollEnabled = true
      faderPanGestureRecognizer.isEnabled = false
      faderViews.forEach({ $0.panGestureRecognizer.isEnabled = true })
      faderViews = []
    }
  }

  // MARK: Panning

  /// Gets called when user make a pan gesture on scroll view, multiple fader editing mode is on.
  ///
  /// - Parameter pan: The single pan gesture that edits all faders in the scroll view.
  @objc private func handleFaderPanning(pan: UIPanGestureRecognizer) {
    let location = pan.location(in: self)
    if let fader = faderViews.filter({ $0.frame.contains(location) }).first {
      fader.handleGestureRecognizer(gestureRecognizer: pan)
    }
  }

  /// Gets all `LiveFaderView`s in the scroll view recursively. You are free to put your faders in a stack view or a custom container.
  ///
  /// - Parameter view: The optional view property for recursively using.
  /// - Returns: All `LiveFaderView`s in the scroll view and its subviews.
  private func getAllFaderViews(of view: UIView? = nil) -> [LiveFaderView] {
    var views = [LiveFaderView]()
    for subview in view?.subviews ?? subviews {
      if let fader = subview as? LiveFaderView {
        views.append(fader)
      } else if subview.subviews.count > 0 {
        views.append(contentsOf: getAllFaderViews(of: subview))
      }
    }
    return views
  }

  // MARK: UIGestureRecognizerDelegate

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
