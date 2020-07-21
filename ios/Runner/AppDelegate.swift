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
//    var jsExecutable: JSExecutable = JSExecutable(jsString: "function simpleFunction(){var hello = \" Hello World\"; var i = 10; while(i>0){ myconsole(i+' value'); i--;} return 'true'; }")
//    var jsStringRec: String
    
    batteryChannel.setMethodCallHandler({[weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        
        
        switch call.method {
            case "setJsString":
                let jsStringRecieved = call.arguments as! String
//                jsExecutable = JSExecutable(jsString: jsStringRecieved)
                self?.reciveJsString(jsString: jsStringRecieved, result: result)
            case "getBatteryLevel":
                self?.reciveBatteryLevel(result: result)
            case "stopJSExecution":
                let emptyStringRecieved = call.arguments as! String
                self?.stopJsExecution(emtyString: emptyStringRecieved, result: result)
            default:
                result(FlutterMethodNotImplemented)
        }
//        guard call.method == "getBatteryLevel" else {
//
//            result(500)
//            return
//        }
        
        
    })
    
//    "function simpleFunction(){var hello = \" Hello World\"; var i = 10; while(i>0){ myconsole(i+' value'); i--;} return 'true'; }"
    
//    let speechController = SpeechController()
    

    
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
    
    private func reciveJsString(jsString: String, result: FlutterResult){
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let jsStringNew = "function simpleFunction(){" + jsString + " return 'true'; }"
        
        let handler = SpeechRecognitionStreamHandler.shared(jsString: jsStringNew)
        let eventChannelName = "rahatDaBoss.testapp.io/speech"
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(handler)
        
        NSLog("\n" + jsString)
        result("jsStringSet: -> ")
    }
    
    private func stopJsExecution(emtyString: String, result: FlutterResult){
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let handler = SpeechRecognitionStreamHandler.shared(jsString: emtyString)
        let eventChannelName = "rahatDaBoss.testapp.io/speech"
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(handler)
        
        result("jsStringSet: -> ")
    }
}


class JSExecutable {
    let jsString: String
    
    init(jsString:String) {
        self.jsString = jsString
    }
}
