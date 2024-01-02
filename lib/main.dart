import 'package:flutter/material.dart';
import 'package:liu_cinema/login.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {

    return const MaterialApp(

        title: 'CSCI410 Project 2',

        debugShowCheckedModeBanner: false,

        home: Home()

    );

  }

}