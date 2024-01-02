import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liu_cinema/Movies.dart';
// main URL for REST pages
const String _baseURL = 'https://csci410moussayassine.000webhostapp.com';

// class to represent a row from the products table
// note: cid is replaced by category name
class Movies{

  int _id;
  String _genre;
  String _name;
  double _price;
  int _numberOfSeats;
  int _duration;



  Movies(this._id, this._name,  this._price, this._numberOfSeats,
      this._duration,this._genre);

  @override
  String toString() {
    return 'Name: $_name ID: $_id price: $_price Number of Seats: $_numberOfSeats Duration: $_duration Genres: $_genre ' ;
  }
}

// list to hold products retrieved from getProducts
List<Movies> _movies = [];
// asynchronously update _products list
void getMovies(Function(bool success) update) async {
  try {
    final url = Uri.parse('$_baseURL/LIU_Cinema/Movies/getMovies.php');
    final response = await http.get(url)
        .timeout(const Duration(seconds: 20)); // max timeout 5 seconds
    _movies.clear(); // clear old products

    if (response.statusCode == 200) { // if successful call
      final jsonResponse = convert.jsonDecode(response.body); // create dart json object from json array
      for (var row in jsonResponse) { // iterate over all rows in the json array
        Movies m = Movies( // create a product object from JSON row object
            int.parse(row['id']),
            row['name'],
            double.parse(row['price']),
          int.parse(row['numberOfSeats']),
          int.parse(row['duration']),
          row['Genre']
        );
        _movies.add(m); // add the product object to the _products list
      }
      update(true); // callback update method to inform that we completed retrieving data
    }
  }
  catch (e) {
    update(false); // inform through callback that we failed to get data
  }
}


class Showmovies extends StatefulWidget {

  const Showmovies({super.key});

  @override
  State<Showmovies> createState() => _ShowmoviesState();
}

class _ShowmoviesState extends State<Showmovies> {

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
    getMovies(update);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    double width = MediaQuery.of(context).size.width;

    return ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) => Column(children: [
          const SizedBox(height: 10),
          Container(

              color: index % 2 == 0 ? Colors.blue: Colors.grey.shade100,
              padding: const EdgeInsets.all(1),
              width: width * 0.9, child: Row(children: [
            SizedBox(width: width * 0.002),
            Flexible(child: Text(_movies[index].toString(), style: TextStyle(fontSize: width * 0.025 , color: Colors.black)))
          ]))
        ])
    );
  }
}
class ViewMovies extends StatefulWidget {
  const ViewMovies({super.key});

  @override
  State<ViewMovies> createState() => _ViewMoviesState();
}

class _ViewMoviesState extends State<ViewMovies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const AddMovies()));
        }, icon: const Icon(Icons.add))
      ],

        title: const Text('Cinema Movies', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Showmovies(),
    );
  }

}
