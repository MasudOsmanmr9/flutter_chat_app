import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register.dart';

class LoginPage extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passswordController = TextEditingController();
  Service service = Service();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Page'),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter Your Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: TextField(
                controller: passswordController,
                decoration: InputDecoration(
                  hintText: 'Enter Your Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                ),
                onPressed: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  if (!emailController.text.isEmpty &&
                      !passswordController.text.isEmpty) {
                    service.loginuser(context, emailController.text,
                        passswordController.text);
                    pref.setString('email', emailController.text);
                  } else {
                    service.errorBox(
                        context, 'email and password can\'t be emty');
                  }
                },
                child: const Text('Login'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: const Text('I dont Have any account'),
            )
          ],
        ),
      ),
    );
  }
}
