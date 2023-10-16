import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/model/message.dart';

class ChatService extends ChangeNotifier {
  // get auth and firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String receiverID, String message) async {
    // current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentEmailID = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create new message
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentEmailID,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);

    // construct chat room for current and receiver users
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // ensure same chat room for a pair of users
    String chatRoomID = ids.join("_");

    // add message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Get Messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // construct chat room id from user ids
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
