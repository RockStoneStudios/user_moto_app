import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:users_app/authentication/signup_screen.dart';
// import 'package:users_app/global/global_var.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../global/global_var.dart';
import '../methods/common_methods.dart';
import 'package:SopeGo/methods/common_methods.dart';
// import '../pages/home_page.dart';
// import '../widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:SopeGo/authentication/signup_screen.dart';

import '../pages/home_page.dart';
import '../widgets/loading_dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Por favor escriba su email.", context);
    } else if (passwordTextEditingController.text.trim().length < 6) {
      cMethods.displaySnackBar(
          "Tu password debe tener minimo 6 caracteres.", context);
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
      const LoadingDialog(messageText: " Iniciando sesión..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
        .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userFirebase.uid);
      await usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const HomePage()));
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar(
                "Tu estas bloqueado. Contacta admin: rockstonestudios666@gmail.com",
                context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar(
              "su registro no existe como Usuario.", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 22,
              ),
              Image.asset(
                "assets/images/Logo_Login.png",
                width: 290,
                height: 290,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Logueate",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 82, vertical: 10)),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              //textbutton
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => SignUpScreen()));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No tienes cuenta? Registrate",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Aqui',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
