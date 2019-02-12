LiveFader
===

`@IBDesignable` Horizontal or vertical UIControl subclass that can start from bottom or middle of the control.

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

LiveFaderScrollView
----

![alt tag](https://github.com/cemolcay/LiveFader/raw/master/scroll.gif)

* Custom scroll view subclass lets you edit all faders with a single pan gesture recognizer.
* Set its `isFaderPanningEnabled` property to true. 
* It won't let you scroll in this mode because you will use the current pan gesture for editing faders instead of scrolling.
* Finds all `LiveFaderView`s in itself and it's subviews recursively, feel free to add your faders in a stack view or a custom container inside your `LiveFaderScrollView`.
