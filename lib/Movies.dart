import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// domain of your server
const String _baseURL = 'https://csci410moussayassine.000webhostapp.com';
// used to retrieve the key later
EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class AddMovies extends StatefulWidget {
  const AddMovies({super.key});

  @override
  State<AddMovies> createState() => _AddMoviesState();
}

class _AddMoviesState extends State<AddMovies> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _MgidcontrollerMovies = TextEditingController();
  TextEditingController _MnamecontrollerMovies = TextEditingController();
  TextEditingController _MdescreptioncontrollerMovies = TextEditingController();
  TextEditingController _MdurationcontrollerMovies = TextEditingController();
  TextEditingController _MpricecontrollerMovies = TextEditingController();
  TextEditingController _MnumberOfSeatscontrollerMovies = TextEditingController();

  bool _loading = false;


  @override
  void dispose() {

    _MgidcontrollerMovies.dispose();
    _MnamecontrollerMovies.dispose();
    _MdescreptioncontrollerMovies.dispose();
    _MdurationcontrollerMovies.dispose();
    _MpricecontrollerMovies.dispose();
    _MnumberOfSeatscontrollerMovies.dispose();

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
            _encryptedData.remove('myKey').then((success) =>
                Navigator.of(context).pop());
          }, icon: const Icon(Icons.logout))
        ],
          title: const Text('Add a Movie'),backgroundColor: Colors.blue ,
          centerTitle: true,
          // the below line disables the back button on the AppBar
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Form(
          key: _formKey, // key to uniquely identify the form when performing validation
          child: Column(
            children: <Widget>[

              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _MgidcontrollerMovies,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter GID',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a GID';
                  }
                  return null;
                },
              )),
              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _MnamecontrollerMovies,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the movie name',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a movie name';
                  }
                  return null;
                },
              )),

              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _MdurationcontrollerMovies,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter movie duration',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please the movie duration';
                  }
                  return null;
                },
              )),
              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _MpricecontrollerMovies,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter ticket price',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please movie ticket price';
                  }
                  return null;
                },
              )),
              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _MnumberOfSeatscontrollerMovies,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the number of seats',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please number of seats';
                  }
                  return null;
                },
              )),
              const SizedBox(height: 10),
              SizedBox(width: 200, child: TextFormField(controller: _MdescreptioncontrollerMovies,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter movie description',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter movie description';
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
                    newMovie(update, _MnamecontrollerMovies.text.toString(),_MdescreptioncontrollerMovies.text.toString(),
                        int.parse(_MdurationcontrollerMovies.text.toString()) ,double.parse(_MpricecontrollerMovies.text.toString()),
                        int.parse(_MnumberOfSeatscontrollerMovies.text.toString()),int.parse(_MgidcontrollerMovies.text.toString()));
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



void newMovie(Function(String text) update, String name, String description, int duration,double price,int numberOfSeats, int gid) async {
  try {
    String myKey = await _encryptedData.getString('password');

    final response = await http.post(

        Uri.parse('$_baseURL/LIU_Cinema/Movies/addMovie.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }, // convert the cid, name and key to a JSON object
        body: convert.jsonEncode(<String, String>{
          'name': name,
          'description': description,
          'duration' : duration.toString(),
          'price' : price.toString(),
          'numberOfSeats' : duration.toString(),
          'gid':gid.toString(),
          'key': myKey

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