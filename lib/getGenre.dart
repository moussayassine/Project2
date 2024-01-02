import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liu_cinema/Movies.dart';
import 'getMovies.dart';
import 'Genre.dart';
import 'login.dart';
// main URL for REST pages
const String _baseURL = 'https://csci410moussayassine.000webhostapp.com';


// class to represent a row from the products table
// note: cid is replaced by category name
class Genre{
  int _gid;
  String _name;

  Genre(this._gid, this._name);

  @override
  String toString() {
    return 'Genres: $_gid Name: $_name ';
  }
}

// list to hold products retrieved from getProducts
List<Genre> _genres = [];
// asynchronously update _products list
void getGenre(Function(bool success) update) async {
  try {

    final url = Uri.parse('$_baseURL/LIU_Cinema/Genres/getGenres.php');
    final response = await http.get(url)
        .timeout(const Duration(seconds: 20)); // max timeout 5 seconds
    _genres.clear(); // clear old products

    if (response.statusCode == 200) { // if successful call
      final jsonResponse = convert.jsonDecode(response.body); // create dart json object from json array
      for (var row in jsonResponse) { // iterate over all rows in the json array
        Genre g = Genre( // create a product object from JSON row object
            int.parse(row['id']),
            row['name']
        );
        _genres.add(g); // add the product object to the _products list
      }
      update(true); // callback update method to inform that we completed retrieving data

    }
  }
  catch (e) {
    update(false); // inform through callback that we failed to get data
  }
}
class ShowGenres extends StatefulWidget {
  const ShowGenres({super.key});

  @override
  State<ShowGenres> createState() => _ShowGenresState();
}

class _ShowGenresState extends State<ShowGenres> {

  bool _load = false; // used to show products list or progress bar

  void update(bool success) {
    setState(() {
      _load = true; // show product list
      if (!success) { // API request failed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('failed to load data')));
      }
    });
  }

  @override
  void initState() {
    // update data when the widget is added to the tree the first tome.
    getGenre(update);
    super.initState();
  }




  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;


    return ListView.builder(
        itemCount: _genres.length,
        itemBuilder: (context, index) => Column(children: [
          const SizedBox(height: 10),
          Container(

              color: index % 2 == 0 ? Colors.blue: Colors.grey.shade100,
              padding: const EdgeInsets.all(1),
              width: width * 0.9, child: Row(children: [
            SizedBox(width: width * 0.002),
            Flexible(child: Text(_genres[index].toString(), style: TextStyle(fontSize: width * 0.025 , color: Colors.black))),
            Align(
              child:IconButton(onPressed: (){
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => const ViewMovies()));
              }, icon: Icon(Icons.arrow_forward)),

            )







          ])),
        ])
    );




  }

}

class ViewGenre extends StatefulWidget {
  const ViewGenre({super.key});

  @override
  State<ViewGenre> createState() => _ViewGenreState();
}

class _ViewGenreState extends State<ViewGenre> {




  @override
  Widget build(BuildContext context) {




    bool admin = false;
    return Scaffold(

      appBar: AppBar(actions: [
              IconButton(onPressed: () {
                if(admin = true) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) => const AddGenre()));
                }else{
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Please ask the admin to add a genre')));
                }
              }, icon: const Icon(Icons.add))
      ],

        title: const Text('Cinema Genre', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body:
          ShowGenres(),







    );
  }

}

