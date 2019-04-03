//
//  LiveFader.swift
//  LiveFader
//
//  Created by cem.olcay on 11/02/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit

/// A UIControl subclass for creating customisable horizontal or vertical faders.
open class LiveFaderView: UIControl {
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
  public var continuous = true
  /// Control style of the fader. Defaults `fromMiddle`.
  public var style = ControlStyle.fromMiddle { didSet{ setNeedsLayout() }}
  /// Control type of the fader. Defaults vertical.
  public var direction = ControlDirection.vertical { didSet{ setNeedsLayout() }}
  /// Current value of the fader. Defaults 0.
  public var value: Double = 0 { didSet{ setNeedsLayout() }}
  /// Maximum value of the fader. Defaults 0.
  public var minValue: Double = 0 { didSet{ setNeedsLayout() }}
  /// Minimum value of the fader. Defaults 1.
  public var maxValue: Double = 1 { didSet{ setNeedsLayout() }}

  /// Enabled background color.
  public var faderEnabledBackgroundColor: UIColor = .lightGray { didSet{ setupColors() }}
  /// Enabled foreground color.
  public var faderEnabledForegroundColor: UIColor = .blue { didSet{ setupColors() }}
  /// Highlighted background color. If not set, enabled bacground color will be used.
  public var faderHighlightedBackgroundColor: UIColor? { didSet{ setupColors() }}
  /// Highlighted foreground color. If not set, enabled foreground color will be used.
  public var faderHighlightedForegroundColor: UIColor? { didSet{ setupColors() }}
  /// Disabled background color.
  public var faderDisabledBackgroundColor: UIColor? = .lightGray { didSet{ setupColors() }}
  /// Disabled foreground color.
  public var faderDisabledForegroundColor: UIColor? = .blue { didSet{ setupColors() }}

  open override var isEnabled: Bool { didSet { setupColors() }}
  open override var isHighlighted: Bool { didSet { setupColors() }}

  /// Foreground layer rendering the `value` of the fader.
  public var faderLayer = CALayer()
  /// Pan gesture setting the `value`.
  public var panGestureRecognizer = UIPanGestureRecognizer()
  public var tapGestureRecognizer = UITapGestureRecognizer()

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
    // Setup gesture recognizers.
    panGestureRecognizer = UIPanGestureRecognizer()
    panGestureRecognizer.addTarget(self, action: #selector(handleGestureRecognizer(gestureRecognizer:)))
    addGestureRecognizer(panGestureRecognizer)
    tapGestureRecognizer = UITapGestureRecognizer()
    tapGestureRecognizer.addTarget(self, action: #selector(handleGestureRecognizer(gestureRecognizer:)))
    addGestureRecognizer(tapGestureRecognizer)
  }

  // MARK: Lifecyle

  open override func layoutSubviews() {
    super.layoutSubviews()
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    switch (style, direction) {
    case (.fromBottom, .vertical):
      var height = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.height)))
      height = height.isNaN ? 0 : height
      faderLayer.frame = CGRect(
        x: 0,
        y: frame.size.height - height,
        width: frame.size.width,
        height: height)
    case (.fromBottom, .horizontal):
      var width = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.width)))
      width = width.isNaN ? 0 : width
      faderLayer.frame = CGRect(
        x: 0,
        y: 0,
        width: width,
        height: frame.size.height)
    case (.fromMiddle, .vertical):
      let isUp = value > ((maxValue - minValue) / 2.0)
      var height = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.height)))
      height = height.isNaN ? 0 : height
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
      var width = CGFloat(convert(
        value: value,
        inRange: minValue...maxValue,
        toRange: 0...Double(frame.size.width)))
      width = width.isNaN ? 0 : width
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

  /// Sets the colors on enabled/disable/highlighted state changes.
  open func setupColors() {
    backgroundColor = isEnabled ?
      (isHighlighted ? (faderHighlightedBackgroundColor ?? faderEnabledBackgroundColor) : faderEnabledBackgroundColor) :
    faderDisabledBackgroundColor
    faderLayer.backgroundColor = isEnabled ?
      (isHighlighted ? (faderHighlightedForegroundColor?.cgColor ?? faderEnabledForegroundColor.cgColor) : faderEnabledForegroundColor.cgColor) :
      faderDisabledForegroundColor?.cgColor
  }

  // MARK: Actions

  /// Sets the value of the fader.
  ///
  /// - Parameter pan: Pan gesture of the fader.
  @objc public func handleGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
    let touchPoint = gestureRecognizer.location(in: self)

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

    // Draw.
    setNeedsLayout()

    // Inform changes based on continuous behaviour of the control.
    if continuous {
      sendActions(for: .valueChanged)
    } else {
      if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
        sendActions(for: .valueChanged)
      }
    }
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
