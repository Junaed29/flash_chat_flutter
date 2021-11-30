import 'package:flash_chat_flutter/constants.dart';
import 'package:flash_chat_flutter/screens/chat_screen.dart';
import 'package:flash_chat_flutter/screens/login_screen.dart';
import 'package:flash_chat_flutter/screens/registration_screen.dart';
import 'package:flash_chat_flutter/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.black54),
          subtitle1: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: toLoginScreen,
      routes: {
        toWelcomeScreen: (context) => WelcomeScreen(),
        toChatScreen: (context) => ChatScreen(),
        toLoginScreen: (context) => LoginScreen(),
        toRegistrationScreen: (context) => RegistrationScreen(),
      },
    );
  }
}
