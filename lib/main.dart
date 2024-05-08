import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:SopeGo/appInfo/app_info.dart';
import 'package:SopeGo/authentication/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:SopeGo/pages/home_page.dart';
import 'firebase_options.dart';
import 'package:SopeGo/dialogs/location_permission_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final permissionStatus = await Permission.locationWhenInUse.status;
  if (permissionStatus.isDenied) {
    runApp(const LocationPermissionApp());
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SopeGo',
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
        home: FirebaseAuth.instance.currentUser == null
            ? const LoginScreen()
            : const HomePage(),
      ),
    );
  }
}
