import UIKit
import Flutter
import JavaScriptCore
import Speech

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery", binaryMessenger: controller.binaryMessenger)
    
    
    batteryChannel.setMethodCallHandler({[weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        
        guard call.method == "getBatteryLevel" else {
            
            result(500)
            return
        }
        
        self?.reciveBatteryLevel(result: result)
    })
    
    
    let handler = SpeechRecognitionStreamHandler()
//    let speechController = SpeechController()
    
    let eventChannelName = "rahatDaBoss.testapp.io/speech"
    let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(handler)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func reciveBatteryLevel(result: FlutterResult){
        let device = UIDevice.current
        
        device.isBatteryMonitoringEnabled = true
        
        if device.batteryState == UIDevice.BatteryState.unknown{
            result(FlutterError(code: "UNAVAILABLE", message: "Battery ino Unavailabel", details: nil))
        } else{
            result(Int(device.batteryLevel * 100))
        }
    }
}


