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

SwiftUI Bridge
---

You can use it with SwiftUI  
https://gist.github.com/cemolcay/8cf7a413e4fcc20bc8c456bc0a5832be  

App Store
----

This library used in my apps in App Store, check them up!  
* [StepBud](https://itunes.apple.com/us/app/stepbud-auv3-midi-sequencer/id1453104408?mt=8) (iOS, AUv3)
* [ArpBud 2](https://apps.apple.com/us/app/arpbud-2-auv3-midi-arpeggiator/id1500403326) (iOS, AUv3, M1)  
* [PolyBud](https://apps.apple.com/us/app/polybud-polyrhythmic-sequencer/id1624211288) (iOS, AUv3, M1) 

