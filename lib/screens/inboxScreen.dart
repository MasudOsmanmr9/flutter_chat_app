import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/dataModle/chatInfo.dart';
import 'package:flutter_application_1/firebaseHelper.dart';
import 'package:flutter_application_1/screens/chatscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dataModle/user.dart';

var loginUser = FirebaseAuth.instance.currentUser;
UserModel? globalUserData;

class InboxScreen extends StatefulWidget {
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  Service service = Service();

  UserModel? userData;

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
    globalUserData = userData = Provider.of<UserModel>(context, listen: false);
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ListTile(
          title: Text(userData!.name),
          subtitle: Text(userData!.email),
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
                      // reverse: true,
                      child: ShowMessageLists(currentUser: userData)
                      //child: Container()
                      ))),
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
                          return x['email'] != globalUserData?.email
                              ? buildChatBubble(x: x)
                              : Container();
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
        Provider.of<pairedUserModel>(context, listen: false).addUserInfo(
            x['name'].toString().trim(),
            x['email'].toString().trim(),
            x['uuid'].toString().trim());
        pairedUserModel pairedUser =
            Provider.of<pairedUserModel>(context, listen: false);
        print("${globalUserData!.name.trim()}-${pairedUser.name.trim()}");
        UserModel cuurentUser = Provider.of<UserModel>(context, listen: false);
        print("${cuurentUser.uid.trim()}-${pairedUser.name.trim()}");
        String CurrentUserUid = cuurentUser.uid.trim();
        String PairedUserUid = x['uuid'].toString().trim();
        QuerySnapshot<Map<String, dynamic>> existChat = await FirebaseFirestore
            .instance
            .collection("rooms")
            .where("permission.$CurrentUserUid", isEqualTo: true)
            .where("permission.$PairedUserUid", isEqualTo: true)
            .get();

        if (existChat.size != 0) {
          print('accessing ${existChat.docs.first.id}');
          Provider.of<specificRoomInfo>(context, listen: false).chatRoomId =
              existChat.docs.first.id;
          Provider.of<specificRoomInfo>(context, listen: false).pairedUserList =
              [CurrentUserUid.toString(), PairedUserUid.toString()];

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatScreen()));
          return;
        }

        print(
            'exxxxxxxxxxxxxxxxisst chaaaaaaaaaaaaaaaaaaaaaaaat ${existChat.docs} size ${existChat.size} and permission.$CurrentUserUid');

        DocumentReference<Map<String, dynamic>> roomDoc =
            await FirebaseFirestore.instance.collection("rooms").add({
          'pairs': [globalUserData!.name.trim(), x['name'].toString().trim()],
          'pairsUid': [CurrentUserUid, PairedUserUid],
          'pairsEmail': [cuurentUser.email, pairedUser.email],
          'permission': {
            CurrentUserUid.toString(): true,
            PairedUserUid.toString(): true
          },
          'time': DateTime.now(),
          'updated-time': DateTime.now()
        });

        Provider.of<specificRoomInfo>(context, listen: false).chatRoomId =
            roomDoc.id;
        Provider.of<specificRoomInfo>(context, listen: false).pairedUserList = [
          globalUserData!.name.trim(),
          x['name'].toString().trim()
        ];

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));

        // .collection("messages")
        // .doc("message1");
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

class ShowMessageLists extends StatefulWidget {
  UserModel? currentUser;
  String? CurrentUserUid;

  ShowMessageLists({
    Key? key,
    required this.currentUser,
  }) : super(key: key) {
    CurrentUserUid = currentUser?.uid.trim();
    //print("permission.$CurrentUserUid");
  }

  @override
  State<ShowMessageLists> createState() => _ShowMessageListsState();
}

class _ShowMessageListsState extends State<ShowMessageLists> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // stream: FirebaseFirestore.instance
        //     .collection("rooms")
        //     .where("permission.${widget.CurrentUserUid}".trim(),
        //         isEqualTo: true)
        //     .orderBy('updated-time', descending: true)
        //     .snapshots(),
        stream: FirebaseFirestore.instance
            .collection("rooms")
            .where('pairsUid', arrayContains: globalUserData?.uid)
            .orderBy('updated-time', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot);
          if (!snapshot.hasData) {
            return const Center(
              // child: CircularProgressIndicator(),
              child: const Text('Data exist? checking'),
            );
          }

          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //child: CircularProgressIndicator(),
              child: const Text('Connection state waiting!!'),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              shrinkWrap: true,
              primary: true,
              //reverse: true,
              physics: const ScrollPhysics(),
              itemBuilder: (context, i) {
                //current user Info
                UserModel currentUser =
                    Provider.of<UserModel>(context, listen: false);
                String CurrentUserUid = currentUser.uid.trim();

                //paired user Info

                QueryDocumentSnapshot x = snapshot.data!.docs[i];
                List<String> pairedUserList = List<String>.from(x['pairs']);
                List<String> pairedUserUidList =
                    List<String>.from(x['pairsUid']);
                List<String> pairedUserEmailList =
                    List<String>.from(x['pairsEmail']);

                String PairedUserName = pairedUserList.firstWhere(
                    (i) => i != currentUser.name,
                    orElse: () => null!);
                String PairedUserUid = pairedUserUidList.firstWhere(
                    (i) => i != currentUser.uid,
                    orElse: () => null!);
                String PairedUserEmail = pairedUserEmailList.firstWhere(
                    (i) => i != currentUser.email,
                    orElse: () => null!);

                return InkWell(
                  key: UniqueKey(),
                  onTap: () async {
                    print('masud osman $PairedUserName');
                    QuerySnapshot<Map<String, dynamic>> existChat =
                        await FirebaseFirestore.instance
                            .collection("rooms")
                            .where("permission.$CurrentUserUid",
                                isEqualTo: true)
                            .where("permission.$PairedUserUid", isEqualTo: true)
                            .get();
                    print(
                        'existChat dataaaaaaaaaaaaaaaaaaaaaaa $CurrentUserUid $PairedUserUid');
                    print(existChat.size);

                    if (existChat.size != 0) {
                      Provider.of<pairedUserModel>(context, listen: false)
                          .addUserInfo(
                              PairedUserName, PairedUserEmail, PairedUserUid);
                      print('accessing ${existChat.docs.first.id}');
                      Provider.of<specificRoomInfo>(context, listen: false)
                          .chatRoomId = existChat.docs.first.id;
                      Provider.of<specificRoomInfo>(context, listen: false)
                          .pairedUserList = [
                        CurrentUserUid.toString(),
                        PairedUserUid.toString()
                      ];

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen()));
                      return;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10.0, // soften the shadow
                          spreadRadius: 5.0, //extend the shadow
                          offset: Offset(
                            0.0, // Move to right 10  horizontally
                            10.0, // Move to bottom 10 Vertically
                          ),
                        )
                      ],
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(PairedUserName),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('tap to read messages'),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
