import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ingpo_game/constant.dart';
import 'package:ingpo_game/models/api_response.dart';
import 'package:ingpo_game/models/user.dart';
import 'package:ingpo_game/screens/register.dart';
import 'package:ingpo_game/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Login extends StatefulWidget {
  // const Login({ Key? key }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body:Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(32),
          children: [
            Text('Ingpo Game',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 40),
              ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: txtEmail,
              validator: (val) => val!.isEmpty ? 'Invalid email' : null,
              decoration: fInputDecoration('Email'),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
                obscureText: true,
                controller: txtPassword,
                validator: (val) =>
                    val!.isEmpty ? 'Invalid email or password' : null,
                decoration: fInputDecoration('Password')),
            SizedBox(
              height: 15,
            ),
            loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : fTextButton(
                    'Login',
                    () {
                      if (formkey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          _loginUser();
                        });
                      }
                    },
                  ),
            SizedBox(
              height: 15,
            ),
            fHint('Belum punya akun? ', 'Register', () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Register()),
                  (route) => false);
            }),
          ],
        ),
      ),
    );
  }
}
