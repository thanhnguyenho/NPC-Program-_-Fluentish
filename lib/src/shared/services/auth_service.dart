import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Auth {
  //allows app to interact with firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get currently logged in user
  User? get currentUser => _firebaseAuth.currentUser;
  //this determines if home screen or login page is shown
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //gets users preferred name
  Future<String?> getPreferredName() async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    return data?['preferredName'];
  }

  //signs into existing account
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    //calls firebase auth to sign in while removing extra space from email and pw
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  //signs user out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  //creates a new user account
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String preferredName,
    required String dateOfBirth,
    required String phoneNumber,
  }) async {
    //print('Starting registration');
    //create user account in firebase auth
    final UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    //print('Firebase Auth user created');

    final User? user = userCredential.user ?? _firebaseAuth.currentUser;

    if (user == null) {
      //print('User is null after registration');
      return;
    }

    //print('Saving user to Firestore: ${user.uid}');

    try {
      //saves user info to firestore
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'uid': user.uid,
        'email': email.trim(),
        'preferredName': preferredName.trim(),
        'dateOfBirth': dateOfBirth.trim(),
        'phoneNumber': phoneNumber.trim(),
        'username': username.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'profilePicture': null, // Default profile picture
      })
          //aborts if it takes more than 10secs
          .timeout(const Duration(seconds: 10));

      //print('User saved to Firestore');
    } catch (e) {
      //print('Firestore save failed: $e');
    }
  }
}
