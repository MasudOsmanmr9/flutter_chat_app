import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/dataModle/user.dart';
import 'package:flutter_application_1/screens/chatscreen.dart';
import 'package:flutter_application_1/screens/inboxScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:flutter_application_1/screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences pref = await SharedPreferences.getInstance();

  var email = pref.get('email');
  // runApp(MaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   home: email == null ? LoginPage() : ChatScreen(),
  //   //home: LoginPage(),
  // ));
  runApp(MultiProvider(
      providers: [Provider<UserModel>(create: (_) => UserModel())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: email == null ? LoginPage() : ChatScreen(),
        //home: LoginPage(),
      )));
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: email == null? LoginPage() : ChatScreen(),
//     );
//   }
// }
