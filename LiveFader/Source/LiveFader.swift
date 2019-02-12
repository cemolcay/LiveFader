//
//  LiveFader.swift
//  LiveFader
//
//  Created by cem.olcay on 11/02/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit

/// A UIControl subclass for creating customisable horizontal or vertical faders.
@IBDesignable open class LiveFaderView: UIControl {
  /// Fader's control direction of the fader.
  public enum ControlDirection {
    /// Horizontal fader.
    case horizontal
    /// Vertical fader.
    case vertical
  }

  /// Fader's contol style.
  public enum ControlStyle {
    /// Starts from bottom on vertical faders, starts from left end on horizontal faders.
    case fromBottom
    /// Starts from middle.
    case fromMiddle
  }

  /// Whether changes in the value of the knob generate continuous update events. Defaults true.
  @IBInspectable public var continuous = true
  /// Control style of the fader. Defaults `fromMiddle`.
  public var style = ControlStyle.fromMiddle
  /// Control type of the fader. Defaults vertical.
  public var direction = ControlDirection.vertical
  /// Current value of the fader. Defaults 0.
  @IBInspectable public var value: Double = 0
  /// Maximum value of the fader. Defaults 0.
  @IBInspectable public var minValue: Double = 0
  /// Minimum value of the fader. Defaults 1.
  @IBInspectable public var maxValue: Double = 1

  /// Enabled background color.
  @IBInspectable public var faderEnabledBackgroundColor: UIColor = .lightGray
  /// Enabled foreground color.
  @IBInspectable public var faderEnabledForegroundColor: UIColor = .blue
  /// Highlighted background color. If not set, enabled bacground color will be used.
  @IBInspectable public var faderHighlightedBackgroundColor: UIColor?
  /// Highlighted foreground color. If not set, enabled foreground color will be used.
  @IBInspectable public var faderHighlightedForegroundColor: UIColor?
  /// Disabled background color.
  @IBInspectable public var faderDisabledBackgroundColor: UIColor? = .lightGray
  /// Disabled foreground color.
  @IBInspectable public var faderDisabledForegroundColor: UIColor? = .blue

  /// Foreground layer rendering the `value` of the fader.
  public var faderLayer = CALayer()
  /// Pan gesture setting the `value`.
  public var panGestureRecognizer = UIPanGestureRecognizer()

  open override var isEnabled: Bool {
    didSet {
      backgroundColor = isEnabled ? faderEnabledBackgroundColor : faderDisabledBackgroundColor
      faderLayer.backgroundColor = isEnabled ? faderEnabledForegroundColor.cgColor : faderDisabledForegroundColor?.cgColor
    }
  }

  open override var isHighlighted: Bool {
    didSet {
      backgroundColor = isEnabled ?
        (isHighlighted ? (faderHighlightedBackgroundColor ?? faderEnabledBackgroundColor) : faderEnabledBackgroundColor) :
        faderDisabledBackgroundColor
      faderLayer.backgroundColor = isEnabled ?
        (isHighlighted ? (faderHighlightedForegroundColor?.cgColor ?? faderEnabledForegroundColor.cgColor) : faderEnabledForegroundColor.cgColor) :
        faderDisabledForegroundColor?.cgColor
    }
  }

  // MARK: Init

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  /// Initializes the fader view.
  public func commonInit() {
    layer.addSublayer(faderLayer)
    // Setup colors.
    backgroundColor = isEnabled ? faderEnabledBackgroundColor : faderDisabledForegroundColor
    faderLayer.backgroundColor = isEnabled ? faderEnabledForegroundColor.cgColor : faderDisabledForegroundColor?.cgColor
    // Setup gesture recognizers.
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
    addGestureRecognizer(panGestureRecognizer)
  }

  // MARK: Lifecyle

  open override func layoutSubviews() {
    super.layoutSubviews()
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    switch (style, direction) {
    case (.fromBottom, .vertical):
      let height = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.height)))
      faderLayer.frame = CGRect(
        x: 0,
        y: frame.size.height - height,
        width: frame.size.width,
        height: height)
    case (.fromBottom, .horizontal):
      let width = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.width)))
      faderLayer.frame = CGRect(
        x: 0,
        y: 0,
        width: width,
        height: frame.size.height)
    case (.fromMiddle, .vertical):
      let isUp = value > ((maxValue - minValue) / 2.0)
      let height = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.height)))
      if isUp {
        faderLayer.frame = CGRect(
          x: 0,
          y: frame.size.height - height,
          width: frame.size.width,
          height: (frame.size.height / 2.0) - (frame.size.height - height))
      } else {
        faderLayer.frame = CGRect(
          x: 0,
          y: frame.size.height / 2.0,
          width: frame.size.width,
          height: (frame.size.height - height) - (frame.size.height / 2.0))
      }
    case (.fromMiddle, .horizontal):
      let isUp = value > ((maxValue - minValue) / 2.0)
      let width = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.width)))
      if isUp {
        faderLayer.frame = CGRect(
          x: frame.size.width / 2.0,
          y: 0,
          width: width - (frame.size.width / 2.0),
          height: frame.size.height)
      } else {
        faderLayer.frame = CGRect(
          x: width,
          y: 0,
          width: (frame.size.width / 2.0) - width,
          height: frame.size.height)
      }
    }
    CATransaction.commit()
  }

  open override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    layoutSubviews()
  }

  // MARK: Actions

  /// Sets the value of the fader.
  ///
  /// - Parameter pan: Pan gesture of the fader.
  @objc func didPan(pan: UIPanGestureRecognizer) {
    let touchPoint = pan.location(in: self)

    // Calculate value.
    switch direction {
    case .vertical:
      let newValue = maxValue - Double(convert(
        value: touchPoint.y,
        inRange: 0...frame.size.height,
        toRange: CGFloat(minValue)...CGFloat(maxValue)))
      value = max(minValue, min(maxValue, newValue))
    case .horizontal:
      let newValue = Double(convert(
        value: touchPoint.x,
        inRange: 0...frame.size.width,
        toRange: CGFloat(minValue)...CGFloat(maxValue)))
      value = max(minValue, min(maxValue, newValue))
    }

    // Inform changes based on continuous behaviour of the control.
    if continuous {
      sendActions(for: .valueChanged)
    } else {
      if pan.state == .ended || pan.state == .cancelled {
        sendActions(for: .valueChanged)
      }
    }

    // Draw.
    setNeedsLayout()
  }

  // MARK: Utils

  /// Converts a value in a range to a value in another range.
  ///
  /// - Parameters:
  ///   - value: Value you want to convert.
  ///   - inRange: The range of the value you want to convert.
  ///   - toRange: The range you want your new value converted in.
  /// - Returns: Converted value in a new range.
  private func convert<T: FloatingPoint>(value: T, inRange: ClosedRange<T>, toRange: ClosedRange<T>) -> T {
    let oldRange = inRange.upperBound - inRange.lowerBound
    let newRange = toRange.upperBound - toRange.lowerBound
    return (((value - inRange.lowerBound) * newRange) / oldRange) + toRange.lowerBound
  }
}
