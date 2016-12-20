//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/13/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let gcmMessageIDKey = "gcm.message_id"
  let gcmMessageKey = "gcm.message"

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // register for remote notification
    self.registerForRemoteNotification(application)

    // configure Firebase
    FIRApp.configure()

    // Add observer for InstanceID token refresh callback.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.tokenRefreshNotification),
      name: .firInstanceIDTokenRefresh,
      object: nil
    )

    return true
  }

  func registerForRemoteNotification(_ application: UIApplication) {
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if #available(iOS 10.0, *) {
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in }
      )

      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self

      // For iOS 10 data message (sent via FCM)
      FIRMessaging.messaging().remoteMessageDelegate = self
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()
  }

  // [START receive_message]
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    // Print message ID.
    if let messageAPS = userInfo["aps"] as? Dictionary<String, AnyObject> {
      if let alert = messageAPS["alert"] as? Dictionary<String, String> {
        let body = alert["body"]
        let title = alert["title"]
        AppUtils.showMessage(controller: (self.window?.rootViewController)! ,
                             title: title!,
                             message: body!)
      }
      if let body = messageAPS["alert"] as? String {
        AppUtils.showMessage(controller: (self.window?.rootViewController)! ,
                             message: body)
      }
    }

  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    completionHandler(UIBackgroundFetchResult.newData)
  }
  // [END receive_message]

  // [START refresh_token]
  func tokenRefreshNotification(_ notification: Notification) {
    if let refreshedToken = FIRInstanceID.instanceID().token() {
      print("InstanceID token: \(refreshedToken)")
    }

    // Connect to FCM since connection may have failed when attempted before having a token.
    connectToFcm()
  }
  // [END refresh_token]

  // [START connect_to_fcm]
  func connectToFcm() {
    FIRMessaging.messaging().connect { (error) in
      if error != nil {
        print("Unable to connect with FCM. \(error)")
      } else {
        print("Connected to FCM.")
      }
    }
  }
  // [END connect_to_fcm]

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    AppUtils.showMessage(
      controller: (self.window?.rootViewController)!,
      message: "Unable to register for remote notifications: \(error.localizedDescription)"
    )
  }

  // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
  // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
  // the InstanceID token.
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNs token retrieved: \(deviceToken)")

    // With swizzling disabled you must set the APNs token here.
    // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
  }

  // [START connect_on_active]
  func applicationDidBecomeActive(_ application: UIApplication) {
    connectToFcm()
  }
  // [END connect_on_active]

  // [START disconnect_from_fcm]
  func applicationDidEnterBackground(_ application: UIApplication) {
    FIRMessaging.messaging().disconnect()
    print("Disconnected from FCM.")
  }
  // [END disconnect_from_fcm]
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    if let messageAPS = userInfo["aps"] as? Dictionary<String, AnyObject> {
      if let alert = messageAPS["alert"] as? Dictionary<String, String> {
        let body = alert["body"]
        let title = alert["title"]
        AppUtils.showMessage(controller: (self.window?.rootViewController)! ,
                             title: title!,
                             message: body!)
      }
      if let body = messageAPS["alert"] as? String {
        AppUtils.showMessage(controller: (self.window?.rootViewController)! ,
                             message: body)
      }
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)
  }
}
// [END ios_10_message_handling]

// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
  // Receive data message on iOS 10 devices while app is in the foreground.
  func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
    print(remoteMessage.appData)
  }
}
// [END ios_10_data_message_handling]

