import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zefyr/zefyr.dart';

typedef void Listener(dynamic msg);
typedef void CancelListening();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static const platForm = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level';
  List<String> res = [];
  TextEditingController jsInputController = TextEditingController();
  StreamSubscription subscription;
  final String jsString = "var hello = \" Hello World\"; var i = 10; while(i>0){ myconsole(i+' value'); i--;}";

  static final jsInputMethodChannel = "jsCode.String.input";
  final jsStringInputMethod = MethodChannel(jsInputMethodChannel);

  final eventChannel = EventChannel("rahatDaBoss.testapp.io/speech");
  final jsEventChannel = EventChannel("rahatdaboss.testApp.io/jScript");
  Function subscriptionCallback;

  CancelListening startEvaluation(String jsCode){
    var subscription = this.jsEventChannel.receiveBroadcastStream().listen(jsResultHandler, onError:jsErrorHandler);

    return (){
      subscription.cancel();
    };
  }

  jsResultHandler(dynamic event){
    final String normalizedEvent = event.toLowerCase();
    print("Hello this is an event js");
    print(normalizedEvent);
    setState(() {
      res.add(normalizedEvent);
    });

  }

  startEditor() async {
    await this.jsStringInputMethod.invokeListMethod("start", jsString);
  }
  @override
  void initState() { 
    // subscription = this.eventChannel.receiveBroadcastStream().listen(speechResultHandler, onError: speechResultErrorHandler);
    // await Future.delayed(Duration(seconds: 3 ));
    // subscriptionCallback =  subscription;
    // startEditor();
    super.initState();
    
  }
  jsErrorHandler(dynamic error) => print("Recived Error ${error.message}");

  Function startListening() {
    subscription = this.eventChannel.receiveBroadcastStream().listen(speechResultHandler, onError: speechResultErrorHandler);
  }

  void cancelListening() async {

    final result = await platForm.invokeMethod('stopJSExecution', "");
  }
  speechResultHandler(dynamic event){
    final String normalizedEvent = event.toLowerCase();
    print(normalizedEvent);
    setState(() {
      res.add(normalizedEvent);
    });
    
  }

  speechResultErrorHandler(dynamic error) => print("REcived Error ${error.message}");

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    print(jsInputController.text);
    try{
      final String argument = 'Hello';

      print(jsInputController.text);
      print(jsInputController.text.replaceAll(RegExp(r'console.log'), 'myconsole'));
      // return true;
      // final int result = await platForm.invokeMethod('getBatteryLevel', argument);
      final result = await platForm.invokeMethod('setJsString', jsInputController.text.replaceAll(RegExp(r'console.log'), 'myconsole'));
      print(result);
      batteryLevel = 'Battery Level at $result % .';
    } on PlatformException catch(err){
      batteryLevel = 'Failed to get battery level: ${err.message}';
    }

    // setState(() {
    //   _batteryLevel = batteryLevel;
    // });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Expanded(
                child: TextField(
                controller: jsInputController..text = "var hello = \" Hello World\"; var i = 10; while(i>0){ console.log(i+' value'); i--;}",
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            Text("Js OUtput")
          ]
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () async {
              await _getBatteryLevel();
              // await Future.delayed(Duration(seconds: 3));
              startListening();
            },
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(
            height:10
          ),
          FloatingActionButton(
            onPressed: () {
              // print(subscriptionCallback.toString());
              // subscriptionCallback.call();
              // cancelListening();

              print("Cancel button called");
              print(subscription.toString());
              subscription.cancel();
            },
            child: Icon(Icons.stop),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  
}
