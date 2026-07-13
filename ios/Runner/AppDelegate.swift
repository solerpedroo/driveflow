import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var pendingShortcutUrl: URL?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let shortcut = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
      pendingShortcutUrl = Self.url(for: shortcut)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    guard let url = Self.url(for: shortcutItem) else {
      completionHandler(false)
      return
    }
    DispatchQueue.main.async {
      _ = application.open(url)
    }
    completionHandler(true)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let url = pendingShortcutUrl {
      pendingShortcutUrl = nil
      DispatchQueue.main.async {
        _ = UIApplication.shared.open(url)
      }
    }
  }

  private static func url(for shortcutItem: UIApplicationShortcutItem) -> URL? {
    let path: String?
    switch shortcutItem.type {
    case "com.driveflow.driveflow.shift_start":
      path = "driveflow://shift/start"
    case "com.driveflow.driveflow.quick_earning":
      path = "driveflow://earning/quick"
    case "com.driveflow.driveflow.shift_mode":
      path = "driveflow://shift"
    default:
      path = nil
    }
    guard let path else { return nil }
    return URL(string: path)
  }
}
