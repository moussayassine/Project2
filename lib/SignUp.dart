import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'Genre.dart';
import 'package:liu_cinema/login.dart';

const String _baseURL = 'https://csci410moussayassine.000webhostapp.com';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  final TextEditingController _SemailController = TextEditingController();
  final TextEditingController _SpasswordController = TextEditingController();
  final TextEditingController _SnameController = TextEditingController();
  final TextEditingController _SphoneController = TextEditingController();
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
  bool _loading = false;

  void updateMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  void navigate(bool success) {
    if (success) { // open the Add Category page if successful
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const Home()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('failed to set key')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUp to Liu Cinema'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextField(
                obscureText: false,
                enableSuggestions: false,
                autocorrect: false,
                controller: _SnameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Full Name',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextField(
                obscureText: false,
                enableSuggestions: false,
                autocorrect: false,
                controller: _SemailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Email',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextField(
                obscureText: false,
                enableSuggestions: false,
                autocorrect: false,
                controller: _SphoneController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Phone',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: _SpasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                SignUp(
                  updateMessage,
                  _SnameController.text.toString(),
                  _SemailController.text.toString(),
                  _SphoneController.text.toString(),
                  _SpasswordController.text.toString(),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void SignUp(
      Function(String text) updateMessage, String name, String email, String phone, String password) async {
    try {
      final url = Uri.parse('$_baseURL/LIU_Cinema/Users/SignUp.php');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 200) {
        navigate(true);
      }
      else if (response.statusCode == 401)
      {
        updateMessage(response.body);
      }

    } catch (e) {
      updateMessage("connection error");
    }
  }
}