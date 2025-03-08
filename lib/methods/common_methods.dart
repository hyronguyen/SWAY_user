import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommonMethods {
////////////////////////////// METHOD FUNCTION //////////////////////////////////////
  void ShowUpMessage(BuildContext context, String content){
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(content: Text(content)),
      );
  }
}

