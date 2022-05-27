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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
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

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    // getToken();
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

  // void initMessaging() {
  //   var androiInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iosInit = IOSInitializationSettings();
  //   var initSettings =
  //       InitializationSettings(android: androiInit, iOS: iosInit);
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   flutterLocalNotificationsPlugin.initialize(initSettings);
  //   var androidDetails = AndroidNotificationDetails('1', 'default',
  //       channelDescription: "Channel Description",
  //       importance: Importance.high,
  //       priority: Priority.high);
  //   var iosDetails = IOSNotificationDetails();
  //   var generalNotificationDetails =
  //       NotificationDetails(android: androidDetails, iOS: iosDetails);
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     RemoteNotification notification = message.notification!;
  //     AndroidNotification android = message.notification!.android!;
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(notification.hashCode,
  //           notification.title, notification.body, generalNotificationDetails);
  //     }
  //   });
  //   getToken();
  // }

  void initMessaging() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@mipmap/ic_launcher",
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });

    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: email == null ? LoginPage() : ChatScreen(),
    );
  }
}
