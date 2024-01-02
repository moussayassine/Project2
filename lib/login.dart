import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'getGenre.dart';
import 'Genre.dart';
import 'SignUp.dart';
const String _baseURL = 'https://csci410moussayassine.000webhostapp.com';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
          .push(MaterialPageRoute(builder: (context) => const ViewGenre()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('failed to set key')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Liu Cinema'),
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
                controller: _emailController,
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
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                login(
                    updateMessage,
                  _emailController.text.toString(),
                  _passwordController.text.toString(),
                );

              },
              child: const Text('Sign in'),
            ),


            const SizedBox(height: 20),


            SizedBox(
              child: new InkWell(
                child: new Text('Create a new account', style: const TextStyle(fontSize: 10, color: Colors.indigoAccent ) ,),
                onTap:() {Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Sign()));}
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void login(
      Function(String text) updateMessage, String email, String password) async {
    try {
      final url = Uri.parse('$_baseURL/LIU_Cinema/Users/SignIn.php');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 200) {
        _encryptedData.setString('email', email);
        _encryptedData.setString('password', password).then((bool success) {
          if (success) {
            updateMessage(response.body);

          }
        });

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