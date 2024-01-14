import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mess_management_system/firebase_options.dart';
import 'package:mess_management_system/models/user.dart';
import 'package:mess_management_system/screens/wrapper.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Userdef?>.value(
      value: AuthService().user,
      catchError: (_, __) {
        return null;
      },
      initialData: null,
      child: MaterialApp(
        home: Wrapper(),
        theme: ThemeData(
          fontFamily: 'Salsa',
        ),
      ),
    );
  }
}
