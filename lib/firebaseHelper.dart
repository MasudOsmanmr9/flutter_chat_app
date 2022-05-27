// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/dataModle/user.dart';
import 'package:flutter_application_1/screens/chatscreen.dart';
import 'package:flutter_application_1/screens/inboxScreen.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:provider/provider.dart';

class Service {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  String? signedUserId;
  void createUser(context, email, password, name) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((signedInUser) {
        store.collection('Users').doc(signedInUser.user?.uid).set({
          'email': email,
          'name': name,
          'uuid': signedInUser.user?.uid,
        });
        signedUserId = signedInUser.user?.uid;
      }).then((value) {
        print('this is value after firestore user entry $signedUserId');
        Provider.of<UserModel>(context, listen: false)
            .addUserInfo(name, email, signedUserId);
        print(
            'uuuuuuuuuuuuuuuuuuuuuuuid stored create user ${Provider.of<UserModel>(context, listen: false).uid}');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => InboxScreen()));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorBox(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        errorBox(context, 'The account already exists for that email.');
      } else {
        errorBox(context, e.code);
      }
    } catch (e) {
      errorBox(context, e);
    }
  }

  void loginuser(context, email, password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot<Map<String, dynamic>> snap =
          await store.collection('Users').doc(credential.user?.uid).get();
      print(snap.data());
      UserConverter user =
          UserConverter.fromMap(snap.data() as Map<String, dynamic>);
      Provider.of<UserModel>(context, listen: false)
          .addUserInfo(user.name, user.email, user.uid);
      // print(
      //     'uuuuuuuuuuuuuuuuuuuuuuuid stored login user ${Provider.of<UserModel>(context, listen: false).uid}');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InboxScreen()));
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'user-not-found') {
        errorBox(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        errorBox(context, 'Wrong password provided for that user.');
      } else {
        errorBox(context, e.code);
      }
    } catch (e) {
      errorBox(context, e);
    }
  }

  void signOut(context) async {
    try {
      await auth.signOut().then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            ((route) => false));
      });
    } catch (e) {
      errorBox(context, e);
    }
  }

  void errorBox(context, e) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: e is String ? Text(e) : Text(e.toString()),
          );
        });
  }
}
