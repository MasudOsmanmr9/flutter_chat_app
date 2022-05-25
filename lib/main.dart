import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/dataModle/user.dart';
import 'package:flutter_application_1/screens/chatscreen.dart';
import 'package:flutter_application_1/screens/inboxScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataModle/chatInfo.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:flutter_application_1/screens/wrapper.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseFirestore.instance.enablePersistence(PersistenceSettings(
  //     synchronizeTabs: Settings(
  //   persistenceEnabled: true,
  //   cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  // )));
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true,
  //   cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  // );

  SharedPreferences pref = await SharedPreferences.getInstance();

  var email = pref.get('email');
  // runApp(MaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   home: email == null ? LoginPage() : ChatScreen(),
  //   //home: LoginPage(),
  // ));
  runApp(MultiProvider(
      providers: [
        Provider<UserModel>(create: (_) => UserModel()),
        Provider<pairedUserModel>(create: (_) => pairedUserModel()),
        Provider<specificRoomInfo>(create: (_) => specificRoomInfo()),
      ],
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyApp(),
          //home: LoginPage(),
        );
      }));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  var email;

  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sharedpredInfo();
    getToken();
    initMessaging();
  }

  void sharedpredInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var email = pref.get('email');
  }

  void getToken() {
    _messaging.getToken().then((value) {
      String? token = value;
      print(token);
    });
  }

  void initMessaging() {
    var androiInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = IOSInitializationSettings();
    var initSettings =
        InitializationSettings(android: androiInit, iOS: iosInit);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSettings);
    var androidDetails = AndroidNotificationDetails('1', 'default',
        channelDescription: "Channel Description",
        importance: Importance.high,
        priority: Priority.high);
    var iosDetails = IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, generalNotificationDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: email == null ? LoginPage() : ChatScreen(),
    );
  }
}
