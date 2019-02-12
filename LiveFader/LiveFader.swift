
//
//  LiveFader.swift
//  LiveFader
//
//  Created by cem.olcay on 11/02/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit

@objc public enum LiveFaderDirection: Int {
  case horizontal
  case vertical
}

@objc public enum LiveFaderStyle: Int {
  case fromBottom
  case fromMiddle
}

@IBDesignable open class LiveFaderView: UIControl {
  /// Whether changes in the value of the knob generate continuous update events. Defaults `true`.
  @IBInspectable public var continuous = true
  @IBInspectable public var style = LiveFaderStyle.fromMiddle
  @IBInspectable public var direction = LiveFaderDirection.vertical
  @IBInspectable public var value: Double = 0
  @IBInspectable public var minValue: Double = 0
  @IBInspectable public var maxValue: Double = 1

  @IBInspectable public var faderEnabledBackgroundColor: UIColor = .lightGray
  @IBInspectable public var faderEnabledForegroundColor: UIColor = .blue
  @IBInspectable public var faderHighlightedBackgroundColor: UIColor?
  @IBInspectable public var faderHighlightedForegroundColor: UIColor?
  @IBInspectable public var faderDisabledBackgroundColor: UIColor? = .lightGray
  @IBInspectable public var faderDisabledForegroundColor: UIColor? = .blue

  private var faderLayer = CALayer()
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

  func commonInit() {
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

  @objc private func didPan(pan: UIPanGestureRecognizer) {
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

  private func convert<T: FloatingPoint>(value: T, inRange: ClosedRange<T>, toRange: ClosedRange<T>) -> T {
    let oldRange = inRange.upperBound - inRange.lowerBound
    let newRange = toRange.upperBound - toRange.lowerBound
    return (((value - inRange.lowerBound) * newRange) / oldRange) + toRange.lowerBound
  }

  private func convert<T: SignedInteger>(value: T, inRange: ClosedRange<T>, toRange: ClosedRange<T>) -> T {
    let oldRange = inRange.upperBound - inRange.lowerBound
    let newRange = toRange.upperBound - toRange.lowerBound
    return (((value - inRange.lowerBound) * newRange) / oldRange) + toRange.lowerBound
  }

  private func convert<T: FloatingPoint>(value: T, inRange: Range<T>, toRange: Range<T>) -> T {
    let oldRange = inRange.upperBound - inRange.lowerBound
    let newRange = toRange.upperBound - toRange.lowerBound
    return (((value - inRange.lowerBound) * newRange) / oldRange) + toRange.lowerBound
  }

  private func convert<T: SignedInteger>(value: T, inRange: Range<T>, toRange: Range<T>) -> T {
    let oldRange = inRange.upperBound - inRange.lowerBound
    let newRange = toRange.upperBound - toRange.lowerBound
    return (((value - inRange.lowerBound) * newRange) / oldRange) + toRange.lowerBound
  }
}
