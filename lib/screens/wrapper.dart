import 'package:flutter/material.dart';
import 'package:mess_management_system/models/user.dart';
import 'package:mess_management_system/screens/authenticate/login.dart';
import 'package:mess_management_system/screens/user/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Userdef?>(context);

    // Return either Home or Authenticate
    if (user == null) {
      return UserLogin();
    } else {
      return HomeScreen();
    }
  }
}
