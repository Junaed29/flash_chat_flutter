import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "chatScreen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  String messageText = "";
  late User loggedInUser;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Something goes wrong"),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, toWelcomeScreen, (route) => false);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStreamWidget(
              fireStore: _fireStore,
              loggedInUser: loggedInUser,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      //Implement send functionality.
                      if (messageText.trim().isNotEmpty) {
                        try {
                          _fireStore.collection("messages").add({
                            "text": messageText,
                            "sender": loggedInUser.email,
                            "timestamp": FieldValue.serverTimestamp()
                          });
                          textEditingController.clear();
                        } catch (e) {
                          showErrorSnackBar();
                          print(e);
                        }
                      }
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStreamWidget extends StatelessWidget {
  const MessagesStreamWidget(
      {Key? key,
      required FirebaseFirestore fireStore,
      required User loggedInUser})
      : _fireStore = fireStore,
        loggedInUser = loggedInUser,
        super(key: key);

  final FirebaseFirestore _fireStore;

  final User loggedInUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            _fireStore.collection("messages").orderBy("timestamp").snapshots(),
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            );
          }
          List<Widget> messageList = [];
          var messages = snapShot.data?.docs.reversed;
          for (var message in messages!) {
            var singleMessage = message.data();
            messageList.add(MessageBubble(
              sender: singleMessage["sender"],
              message: singleMessage["text"],
              isMe: singleMessage["sender"] == loggedInUser.email,
            ));
          }

          return Expanded(
            child: ListView(
              reverse: true,
              children: messageList,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender, required this.message, required this.isMe});

  String sender = "";
  String message = "";
  bool isMe = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topRight: Radius.circular(30)),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                message,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
