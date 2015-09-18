# FSCodeTemplate

[![CI Status](http://img.shields.io/travis/Ferdly Sethio/FSCodeTemplate.svg?style=flat)](https://travis-ci.org/Ferdly Sethio/FSCodeTemplate)
[![Version](https://img.shields.io/cocoapods/v/FSCodeTemplate.svg?style=flat)](http://cocoapods.org/pods/FSCodeTemplate)
[![License](https://img.shields.io/cocoapods/l/FSCodeTemplate.svg?style=flat)](http://cocoapods.org/pods/FSCodeTemplate)
[![Platform](https://img.shields.io/cocoapods/p/FSCodeTemplate.svg?style=flat)](http://cocoapods.org/pods/FSCodeTemplate)

Check [NYTimes Objective-C Style Guide](https://github.com/NYTimes/objective-c-style-guide) for coding & naming style.

## Folder Structure

Lets say your application name is "My Awesome App"

* Application
  * main.m
  * Main.storyboard
  * LaunchScreen.storyboard
  * Info.plist
  * Prefix.pch
  * AppDelegate.h
  * AppDelegate.m
* Constants
* Managers
  * MAAAccountManager.h
  * MAAAccountManager.m
* Models
  * MAAUser.h
  * MAAUser.m
* Controllers
  * Login
    * MAALoginController.h
    * MAALoginController.m
    * MAALogin.storyboard
  * HOme
    * MAAHomeController.h
    * MAAHomeController.m
    * MAAHome.storyboard
* Views
* Resources
  * Fonts
  * Images.xcassets

## Installation

* FSCodeTemplate is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:
```ruby
pod "FSCodeTemplate"
```

* If you move your `Prefix.pch` file to `Application` folder, go to `your target > Build Settings` and change `Prefix Header` from `MyAwesomeApp/Prefix.pch` to `MyAwesomeApp/Application/Prefix.pch`
* If you move your `Info.plist` file to `Application` folder, go to `your target > Build Settings` and change `Info.plist File` from `MyAwesomeApp/Info.plist` to `MyAwesomeApp/Application/info.plist` and go to `your target > Build Phase > Copy Bundle Resources` and remove `info.plist`


## AppDelegate

* Subclass it from `FSAppDelegate`
* Make it as clean as possible
* Do the `UIApplicationDelegate` work inside Managers instead

## Manager

* Subclass it from `FSManager`
* It has following capabilities :
  * Access `UIApplicationDelegate`
  * Add & remove `delegate`
  * Built in `sharedManager`, so you dont have to write it all over again
* Initialize:
```objc
@implementation AppDelegate

- (void)initializeManagers
{
    [MAAAccountManager sharedManager];
}
```

## View Controller

* 1 storyboard 1 controller, load the file faster and cleaner
* Put storyboard under same folder, find faster
* Initialize it from storyboard using:
```objc
[MAALoginController fs_newController];
```

## Author

Ferdly Sethio, bungferdly@gmail.com

## License

FSCodeTemplate is available under the MIT license. See the LICENSE file for more info.
