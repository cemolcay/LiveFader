LiveFader
===

`@IBDesignable` Horizontal or vertical fader that can start from bottom or middle of the control.

Demo
----

![alt tag](https://github.com/cemolcay/LiveFader/raw/master/demo.gif)

Requirements
----

* iOS 9.0+
* Swift 4.2+
* Xcode 10.0+

Install
----

#### Manual

* Import the `LiveFader.swift` file into your codebase

#### Cocoapods

```
pod 'LiveFader'
```

Usage
----

* Create a UIView instance in your storyboard and make it's class to `LiveFaderView`.
* Or create a LiveFaderView programmatically.
* Set the bottom or middle control style with the `style` property.
* Set the horizontal or vertical control type with the `controlType` property.
* You can bind a `@IBAction` to the `LiveFader`'s `valueChanged` event from the storyboard or programmatically.
* You can change the enabled/disabled/highlighted color styles from the `@IBInspectable` in storyboard or programmatically.
* `LiveFaderView` is an open class, so you can subclass it to make it look anything you want, by playing with it's layers or adding new ones.