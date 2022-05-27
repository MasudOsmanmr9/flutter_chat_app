import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/dataModle/user.dart';
import 'package:flutter_application_1/firebaseHelper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../dataModle/chatInfo.dart';

var loginUser = FirebaseAuth.instance.currentUser;

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Service service = Service();
  http.Client client = http.Client();
  final storeMessage = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;
  specificRoomInfo? roomInfo;
  TextEditingController messageInput = TextEditingController();

  UserModel? userData;
  pairedUserModel? pairedInfo;

  getCurrentUser() {
    final user = auth.currentUser;
    if (user != null) {
      loginUser = user;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = Provider.of<UserModel>(context, listen: false);
    roomInfo = Provider.of<specificRoomInfo>(context, listen: false);
    pairedInfo = Provider.of<pairedUserModel>(context, listen: false);
    FirebaseMessaging.instance.subscribeToTopic('myTopic');
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: Text(loginUser!.email.toString()),
        title: ListTile(
          title: Text(pairedInfo!.email),
          subtitle: Text(pairedInfo!.name),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                service.signOut(context);
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.remove('email');
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text('Messages'),
          Expanded(
              child: Container(
                  height: 100,
                  color: Colors.blue[100],
                  child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      reverse: true,
                      child: ShowMessages(
                        roomInfo: roomInfo,
                      )))),
          Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.teal[100]!))),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                      child: TextField(
                    controller: messageInput,
                    decoration: InputDecoration(hintText: 'Enter message...'),
                  )),
                ),
                IconButton(
                    onPressed: sentMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.teal,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  void sentMessage() async {
    print(messageInput.text);
    await storeMessage
        .collection('rooms')
        .doc(roomInfo!.roomId)
        .collection("messages")
        .add({
      'msg': messageInput.text.trim(),
      'user': loginUser?.email.toString(),
      'time': DateTime.now()
    }).then((value) async {
      await storeMessage
          .collection('rooms')
          .doc(roomInfo!.roomId)
          .update({'updated-time': DateTime.now()});
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var body = {
        "to": "/topics/myTopic",
        "notification": {
          "title": "${userData!.name}",
          "body": "${messageInput.text.trim()}",
          "mutable_content": true,
          "sound": "Tri-tone"
        },
        "data": {
          "type": 'order',
          "id": '28',
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      };
      final headers = {
        'content-type': 'application/json',
        'Authorization':
            'key=AAAAIdsPrlI:APA91bGKc6RJ9fFCTXA-e5Obe5h2DQWlbqjIR4KdzwwI9X3zByYz_DpYMxN4E0Nju9hbvjSPUOCabOmT9khCNQI1PKLTmk22etnyt4PCUvomznL_NiHPIezaa32TsTxBA9XQR0zm47ze'
      };

      // final http.Response response = await client.post(url,
      //     body: jsonEncode(body),
      //     encoding: Encoding.getByName('utf-8'),
      //     headers: headers);
      // if (response.statusCode == 200) {
      //   print('notifed successfully');
      // } else {
      //   print('notified unsuccessfull');
      // }
    });
    messageInput.clear();
  }
}

class ShowMessages extends StatelessWidget {
  final specificRoomInfo? roomInfo;
  const ShowMessages({this.roomInfo, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // stream: FirebaseFirestore.instance
        //     .collection('rooms')
        //     .orderBy('time')
        //     .snapshots(),
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomInfo!.roomId)
            .collection("messages")
            .orderBy('time')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot);
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              shrinkWrap: true,
              primary: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, i) {
                QueryDocumentSnapshot x = snapshot.data!.docs[i];
                return ListTile(
                  title: Row(
                    mainAxisAlignment: loginUser!.email == x['user']
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                        x['msg'],
                        textAlign: loginUser!.email == x['user']
                            ? TextAlign.end
                            : TextAlign.start,
                      )),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: loginUser!.email == x['user']
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Text(x['user']),
                    ],
                  ),
                );
                // return Row(
                //   mainAxisAlignment: loginUser!.email == x['user']
                //       ? MainAxisAlignment.end
                //       : MainAxisAlignment.start,
                //   children: [
                //     Column(
                //       children: [
                //         Text(x['msg']),
                //         Text(x['user']),
                //       ],
                //     )
                //   ],
                // );
              });
        });
  }
}
