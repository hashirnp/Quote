import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up method channel for widget deep linking after Flutter engine is ready
    if let controller = window?.rootViewController as? FlutterViewController {
      let widgetChannel = FlutterMethodChannel(
        name: "com.quote.app/widget",
        binaryMessenger: controller.binaryMessenger
      )
      
      widgetChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "getWidgetIntent" {
          // Check if app was opened from widget
          // This will be set when widget is tapped
          result(false) // Default to false, will be set by widget tap handler
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle URL scheme (deep linking from widget)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle quoteapp://daily URL from widget
    if url.scheme == "quoteapp" && url.host == "daily" {
      // Notify Flutter about widget tap
      if let controller = window?.rootViewController as? FlutterViewController {
        let widgetChannel = FlutterMethodChannel(
          name: "com.quote.app/widget",
          binaryMessenger: controller.binaryMessenger
        )
        widgetChannel.invokeMethod("onWidgetTap", arguments: nil)
      }
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
