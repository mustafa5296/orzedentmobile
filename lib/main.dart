import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orzedent/ayarlar.dart';
import 'package:orzedent/login.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();

    var _firebaseMessaging = new FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
    );
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  @override
  Widget build(BuildContext context) {

    

    

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OrzeDent',
         theme: ThemeData(
        primaryColor: Color(0xFF2661FA),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ), 
        home: SplashScreen(
            seconds: 3,
            navigateAfterSeconds: login(),
            title: new Text(
              'OrzeDent Beta MobileApp \n Diş Laboratuvarı İş Takip Yazılımı \n V3.0.0',
              style: new TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            image: new Image.asset(
                'assets/images/source.gif'),
            backgroundColor: Color.fromRGBO(110, 207, 246, 1.0),
            styleTextUnderTheLoader: new TextStyle(),
            photoSize: 200,
            onClick: () => print("Flutter Egypt"),
            loaderColor: Colors.red));
  }
}
