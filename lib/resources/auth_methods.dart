// ignore_for_file: unused_field, avoid_print, unused_local_variable, unused_import
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentuser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentuser.uid).get();

    return model.User.fromSnap(snap);     // made a fuction in user.dart so that baar baar nahi likhna padega.
  }

// signn up the user.
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    // return type changes to future.
    String res = "Some Error Occured.";
    try {
      if (email.isNotEmpty || password.isNotEmpty || bio.isNotEmpty) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);

        String photoUrl = await StorageMehtods().uploadImageToStorage(
            'ProfilePictures',
            file,
            false); // false -> because this is not a post , just profile picture.

        //add user to our database

        model.User user = model.User(
          email: email,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = 'Success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

// To Log In the User.
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occured.";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'Success';
      } else {
        res = "please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
