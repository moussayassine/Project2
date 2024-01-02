import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// domain of your server
const String _baseURL = 'https://csci410moussayassine.000webhostapp.com';
// used to retrieve the key later
EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class AddGenre extends StatefulWidget {
  const AddGenre({super.key});

  @override
  State<AddGenre> createState() => _AddGenreState();
}

class _AddGenreState extends State<AddGenre> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controllerGenre = TextEditingController();

  bool _loading = false;


  @override
  void dispose() {
    _controllerGenre.dispose();

    super.dispose();
  }

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(onPressed: () {
            _encryptedData.remove('email');
            _encryptedData.remove('password').then((success) =>
                Navigator.of(context).pop());
          }, icon: const Icon(Icons.logout))
        ],
          title: const Text('Add Category'),backgroundColor: Colors.blue,
          centerTitle: true,
          // the below line disables the back button on the AppBar
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Form(
          key: _formKey, // key to uniquely identify the form when performing validation
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _controllerGenre,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a new genre',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a genre';
                  }
                  return null;
                },
              )),
              const SizedBox(height: 10),
              ElevatedButton(
                // we need to prevent the user from sending another request, while current
                // request is being processed
                onPressed: _loading ? null : () { // disable button while loading
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });
                    newGenre(update, _controllerGenre.text.toString());
                  }
                },
                child: const Text('Add'),
              ),
              const SizedBox(height: 10),
              Visibility(visible: _loading, child: const CircularProgressIndicator())
            ],
          ),
        )));
  }
}



void newGenre(Function(String text) update, String name) async {
  try {
    String myKey = await _encryptedData.getString('password');

    final response = await http.post(

        Uri.parse('$_baseURL/LIU_Cinema/Genres/addGenre.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }, // convert the cid, name and key to a JSON object
        body: convert.jsonEncode(<String, String>{
           'name': name
          , 'key': myKey
        })).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      // if successful, call the update function
      update(response.body);
    }
  }
  catch(e) {
    update("connection error");
  }
}