import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

var loginUser = FirebaseAuth.instance.currentUser;

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Service service = Service();

  final storeMessage = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;
  TextEditingController messageInput = TextEditingController();

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
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(loginUser!.email.toString()),
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
                      child: ShowMessages()))),
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
                    onPressed: () {
                      print(messageInput.text);
                      storeMessage.collection('messages').doc().set({
                        'msg': messageInput.text.trim(),
                        'user': loginUser?.email.toString(),
                        'time': DateTime.now()
                      });
                      messageInput.clear();
                    },
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
}

class ShowMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .orderBy('time')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      Text(x['msg']),
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
