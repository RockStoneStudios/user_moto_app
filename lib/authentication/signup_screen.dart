import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../methods/common_methods.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialogs.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  final RegExp _emojiRegex = RegExp(
    r"[\u{1F600}-\u{1F64F}" // Emoticons
    r"\u{1F300}-\u{1F5FF}" // Misc Symbols and Pictographs
    r"\u{1F680}-\u{1F6FF}" // Transport and Map
    r"\u{2600}-\u{26FF}" // Misc symbols
    r"\u{2700}-\u{27BF}" // Dingbats
    r"\u{FE0F}]",
    unicode: true,
  );

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("Su Nombre debe tener 4 caracteres.", context);
    } else if (userPhoneTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar("Su Numero celular debe tener 10 numers.", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Por favor escriba un correo valido.", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar("Tu Contraseña debe tener 6 o mas caracteres.", context);
    } else {
      registerNewUser();
    }
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registrando ..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
        .then((userCredential) {
      if (mounted) {
        Navigator.pop(context);
      }
      return userCredential.user;
    }).catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }));

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      Map userDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": "no",
      };
      await usersRef.set(userDataMap);

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
      }
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
              Image.asset(
                "assets/images/logo.png",
                width: 190,
                height: 190,
              ),
              const Text(
                "Crea un Usuario",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextFormField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Nombre",
                        labelStyle: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                        FilteringTextInputFormatter.deny(_emojiRegex),
                      ],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Numero Celular",
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
                      onChanged: (value) {
                        if (_emojiRegex.hasMatch(value)) {
                          setState(() {
                            emailTextEditingController.text = emailTextEditingController.text.replaceAll(_emojiRegex, '');
                            emailTextEditingController.selection = TextSelection.fromPosition(
                              TextPosition(offset: emailTextEditingController.text.length),
                            );
                          });
                        }
                      },
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
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ya tienes cuenta? ",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Logueate',
                      style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
