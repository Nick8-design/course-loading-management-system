import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDao extends ChangeNotifier {
  String errorMsg = 'An error has occurred.';
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  String? userId() {
    return auth.currentUser?.uid;
  }

  String? email() {
    return auth.currentUser?.email;
  }

  /// **Signup method with role saving**
  Future<String?> signup(String email, String password, String role) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user role in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
      });

      notifyListeners();
      return null; // No error
    } on FirebaseAuthException catch (e) {
      if (email.isEmpty) {
        errorMsg = 'Email is blank.';
      } else if (password.isEmpty) {
        errorMsg = 'Password is blank.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'The account already exists for that email.';
      }
      return errorMsg;
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  /// **Login method with role retrieval**
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return 'User role not found.';
      }

      String role = userDoc['role'];
      log('User logged in as: $role');

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (email.isEmpty) {
        errorMsg = 'Email is blank.';
      } else if (password.isEmpty) {
        errorMsg = 'Password is blank. Provide correct details';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMsg = 'Invalid credentials.';
      } else if (e.code == 'user-not-found') {
        errorMsg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Wrong password provided for that user.';
      }
      return errorMsg;
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  /// **Fetch logged-in user's role**
 Future<String?> getUserRole() async {
    if (auth.currentUser == null) return null;

    DocumentSnapshot userDoc =
    await firestore.collection('users').doc(auth.currentUser!.uid).get();

    if (userDoc.exists) {
      return userDoc['role'];
    }
    return null;
  }



  /// **Send password reset email**
  Future<String?> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      } else if (e.code == 'user-not-found') {
        return 'No user found with this email.';
      }
      return 'Something went wrong. Please try again.';
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }




  Future<void> logout() async {
    await auth.signOut();
    notifyListeners();

  }
}
