import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class RegisterPage extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Service service = Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Page'),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Your name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
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
                  padding: EdgeInsets.symmetric(horizontal: 80),
                ),
                onPressed: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  if (!emailController.text.isEmpty &&
                      !passswordController.text.isEmpty) {
                    service.createUser(context, emailController.text,
                        passswordController.text, nameController.text);
                    pref.setString('email', emailController.text);
                    pref.setString('currentUserName', nameController.text);
                  } else {
                    service.errorBox(
                        context, 'email and password can\'t be emty');
                  }
                },
                child: Text('Register'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text('Already have account'),
            )
          ],
        ),
      ),
    );
  }
}
