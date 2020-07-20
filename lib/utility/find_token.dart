import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> findToken() async {
    String token;
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    await firebaseMessaging.getToken().then((value) {
      String string = value.toString();
      // print('token = $token');
     token = string;
    });
     print('token = $token');
    return token;
  }