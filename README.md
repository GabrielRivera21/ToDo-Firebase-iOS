# ToDo-Firebase-iOS
Testing out the Firebase iOS SDK

## Requirements

- Xcode 8.x

## Setup

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

Then inside the project folder run the following command:

```bash
$ pod install
```

Now just open the `ToDoList.xcworkspace` file with Xcode.

### Add Firebase to the App

Now we just need to go to the [Firebase Console](https://console.firebase.google.com) and follow the steps provided here:

1. Create a Firebase project in the Firebase console, click **Create New Project**.

2. Click **Add Firebase to your iOS app** and follow the setup steps. When prompted, enter this app's bundle ID
`com.gabrielrivera.example.ToDoList`. You can change the bundle ID if you wish on the app but it must match in
the Firebase Console.

3. At the end, you'll download a `GoogleService-Info.plist` file, then copy this file into your Xcode project root.
