import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

var loginUser = FirebaseAuth.instance.currentUser;

class InboxScreen extends StatefulWidget {
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
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
          Container(
            height: 60.0,
            child: ShowUsers(),
          ),
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

class ShowUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        child: Row(
          children: [
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Users').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Container(
                    height: 40.0,
                    child: ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        primary: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context, i) {
                          QueryDocumentSnapshot x = snapshot.data!.docs[i];
                          return buildChatBubble(x: x);
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class buildChatBubble extends StatelessWidget {
  const buildChatBubble({
    Key? key,
    required this.x,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> x;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(x['name']);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.remove('email');
        final messageRef = FirebaseFirestore.instance
            .collection("rooms")
            .doc("roomA")
            .collection("messages")
            .doc("message1");
      },
      child: Container(
        // height: 60.0,
        // width: 60.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: Colors.blue[400],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              x['name'],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              shrinkWrap: true,
              primary: true,
              physics: const ScrollPhysics(),
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
              });
        });
  }
}
