
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nestview/homepage/home.dart';
class Loginmethods{
  Future<String> Loginwithep(String email,String password,BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      Navigator.of(context).pushAndRemoveUntil(_createRoute(), (Route route) => false);
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      else{
        return 'something went wrong';
      }
    }
  }

  Future<String> Signinwithep(String email,String password,String username,String mobilenumber,BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      DatabaseReference ref = FirebaseDatabase.instance.ref("users");
      ref.child((credential.user?.uid).toString()).child("username").set(username);
      ref.child((credential.user?.uid).toString()).child("mobile number").set(mobilenumber);
      ref.child((credential.user?.uid).toString()).child("email").set(email);
      Navigator.of(context).push(_createRoute());
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      }else{
        return "something went wrong";
      }
    } catch (e) {
      print(e);
      return "something went wrong";
    }

  }
  Route _createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        }
    );
  }
}
