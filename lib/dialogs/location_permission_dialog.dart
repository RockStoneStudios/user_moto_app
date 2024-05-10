import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:SopeGo/authentication/login_screen.dart';
import 'package:SopeGo/pages/home_page.dart';

class LocationPermissionApp extends StatelessWidget {
  const LocationPermissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SopeGo',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const LocationPermissionDialog(),
    );
  }
}

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_m.jpg',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'SopeGo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SopeGo necesita acceder a tu geolocalizacin para poder mostrar la ruta y el viaje en tiempo real, as como para poder calcular distancia y costos del mismo, incluso cuando la app est cerrada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final permissionStatus = await Permission.locationWhenInUse.request();
                    if (permissionStatus.isGranted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => FirebaseAuth.instance.currentUser == null
                            ? const LoginScreen()
                            : const HomePage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Permitir',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
