
import 'package:flutter/material.dart';

class SnackBarUtils{

  static void showRedSnackBar(String content,BuildContext context){

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content),backgroundColor: Colors.red,));
  }

  static void showGreenSnackBar(String content, BuildContext context){

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content),backgroundColor: Colors.green,));
  }



}