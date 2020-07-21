import UIKit
import Flutter
import JavaScriptCore

class SpeechRecognitionStreamHandler: NSObject, FlutterStreamHandler {
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        
        guard let eventSink = _eventSink else{
//            speechController()
            
            return nil
        }
        eventSink("CAncelling")
        _eventSink = nil
        self.jsContext = JSContext()!
        return nil
    }
    
    static func shared(jsString:String) -> SpeechRecognitionStreamHandler {
        return SpeechRecognitionStreamHandler(jsString: jsString)
    }
    
    private init(jsString:String) {
        self.jsString = jsString
        let myConsoleObject = unsafeBitCast(self.myConsole, to: AnyObject.self)
        
        self.jsContext.setObject(myConsoleObject, forKeyedSubscript: "myconsole" as (NSCopying & NSObjectProtocol))
        _ = self.jsContext.evaluateScript("myconsole")
    }
    private var _eventSink: FlutterEventSink?
    var jsContext = JSContext()!
    var jsString: String;
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        
        

        
        
        _eventSink = events
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.speechController()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(SpeechRecognitionStreamHandler.onStateDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.myConsoleLog(notification:)), name: Notification.Name("DidreciveRAndomString"), object: nil)
        
        return nil
    }
    
//    private let consoleLog: @convention(block) (String) -> Void = { logMessage in
//
//        guard  let eventSink = _eventSink else {
//            return
//        }
//
//        eventSink()
//        print("\nJS Console:", logMessage)
//    }
    
    private func consoleLog(logMessage: String){
    
        guard let eventSink = _eventSink else{
//            speechController()
            
            return
        }
        eventSink(logMessage)
    }
    
    @objc private func onStateDidChange(notification: NSNotification){
        speechController()
    }
    
    let myConsole: @convention(block) (String) -> Void = {
        logMessage in
//        NSLog("\nHello in myconsole")
        NotificationCenter.default.post(name: Notification.Name("DidreciveRAndomString"), object: logMessage)

    }
    
    @objc func myConsoleLog(notification: Notification){
//        NSLog("\nHello in myconsolelog")
        if let mymsg = notification.object as? String{
            self.displayConsole(msg: mymsg)
        }
    }
    
    func displayConsole(msg: String){
//        NSLog("\nHello in displayconsole")
        guard let eventSink = _eventSink else {
            return        }
        
        eventSink("From JS: " + msg)
    }
    func speechController(){
        guard let eventSink = _eventSink else {
            return        }
        
        self.jsContext.exceptionHandler = {context, exception in
            if let exc = exception{
                print(" JS Exception", exc.toString()!)
            }
        }

        print("In speech Controller")
//        let jsVAlue = self.jsContext.evaluateScript("(function(){var myHello = 'Hello World' return myHello; })()")
//        eventSink(jsVAlue?.toString())
        
        eventSink("Event sink before jscontext");
        let jsSourceContents =  self.jsString
        
//        let jsSourceContents =  "function simpleFunction(){var hello = \" Hello World\"; var i = 10;  myconsole(i+' value'); return 'true'; }"
        
        self.jsContext.evaluateScript(jsSourceContents)

        if let functionFullname = self.jsContext.objectForKeyedSubscript("simpleFunction") {

            let hello = functionFullname.call(withArguments: [])
            eventSink(hello?.toString())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
                self.jsContext = JSContext()!
            })
            
        }
    }
    
}
