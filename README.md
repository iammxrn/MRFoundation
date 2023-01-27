# MRFoundation

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MRFoundation.svg)](https://img.shields.io/cocoapods/v/MRFoundation.svg)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-orange.svg?style=flat)](https://www.swift.org/package-manager/)
[![Platform](https://img.shields.io/cocoapods/p/MRFoundation.svg?style=flat)](http://cocoadocs.org/docsets/MRFoundation)

MRFoundation is a library to complement the Swift Standard Library.

## Requirements

- iOS 11.0+
- Xcode 11+
- Swift 5.1+

## Communication

- If you need to **find or understand an API**, check [our documentation](https://iammxrn.github.io/MRFoundation/).
- If you **found a bug**, open an issue. The more detail the better!
- If you **want to contribute**, submit a pull request.


## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate MRFoundation into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'MRFoundation'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but MRFoundation does support its use on supported platforms.

Once you have your Swift package set up, adding MRFoundation as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/djmixroman/MRFoundation.git", .upToNextMajor(from: "1.0.0"))
]
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate MRFoundation into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add MRFoundation as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/djmixroman/MRFoundation.git
```

- Open the new `MRFoundation` folder, and drag the `MRFoundation.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `MRFoundation.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see `MRFoundation.xcodeproj` folder.

- And that's it!

  > The `MRFoundation.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

---

## License

MRFoundation is released under the MIT license. [See LICENSE](https://github.com/djmixroman/MRFoundation/blob/master/LICENSE.md) for details.
