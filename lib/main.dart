import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool isloading = false;
  String errmsg = '';

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    GoogleSignInAccount? guser = _googleSignIn.currentUser;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:
              Text('Auth user (Logged ' + (user == null ? 'out' : 'in') + ')'),
        ),
        body: Center(
          child: Form(
            key: _key,
            child: Column(
              children: [
                TextFormField(
                  validator: validemail,
                  controller: emailcontroller,
                ),
                TextFormField(
                  validator: validpass,
                  controller: passwordcontroller,
                ),
                Text(errmsg),
                Row(
                  children: [
                    TextButton(
                        onPressed: user != null
                            ? null
                            : () async {
                                setState(() {
                                  isloading = true;
                                  errmsg = '';
                                });
                                if (_key.currentState!.validate()) {
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: emailcontroller.text,
                                            password: passwordcontroller.text);
                                  } on FirebaseAuthException catch (error) {
                                    errmsg = error.message!;
                                  }
                                }
                                setState(() => isloading = false);
                              },
                        child: isloading
                            ? CircularProgressIndicator()
                            : Text('Signup')),
                    TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          setState(() {});
                        },
                        child: Text('LogOut')),
                    TextButton(
                        onPressed: user != null
                            ? null
                            : () async {
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: emailcontroller.text,
                                          password: passwordcontroller.text);
                                  errmsg = '';
                                } on FirebaseAuthException catch (error) {
                                  errmsg = error.message!;
                                }
                                setState(() {});
                              },
                        child: Text('Login')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? validemail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty) {
    return 'E-mail address is required';
  }
  String pattern = r'\w+@\w+\.\w';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Invalid E-mail format.';
  return null;
}

String? validpass(String? formpass) {
  if (formpass == null || formpass.isEmpty) {
    return 'Password is required';
  }
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formpass)) {
    return '''
    Password must be at least 8 characters long.
    include an upeercase letter , number and symbol.''';
  }
  return null;
}
