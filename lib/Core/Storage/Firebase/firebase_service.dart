import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Utils/Enums/collection_key.dart';
import 'response_model.dart';
import 'failure_model.dart';

class FirebaseServices {
  FirebaseServices._();

  static final FirebaseServices _instance = FirebaseServices._();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static final _webClientId =
      "231951979413-anlihbi9s6do3h4rm078g54o3u44e5nh.apps.googleusercontent.com";
  static FirebaseServices get instance => _instance;

  FirebaseAuth? _auth;
  FirebaseFirestore? firestore;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      // log('TestFIrebaseServices::: Firebase services initialized.');
    }
  }

  //* Authentication
  Future<ResponseModel> loginAccount(String email, String password) async {
    try {
      UserCredential userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return ResponseModel.success(
        message: 'Login successfully',
        data: userCredential.user?.uid,
      );
    } on FirebaseAuthException catch (signInError) {
      final failure = FailureModel(
        message: 'Firebase Authentication Error during sign in',
        error: signInError,
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    } catch (e) {
      log(e.toString());
      final failure = FailureModel(
        message: 'An unexpected error occurred during login',
        error: e,
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> createAccount(
    Map<String, dynamic> account,
    String id,
  ) async {
    try {
      final userid = id;

      final response = await addData(CollectionKey.users.key, userid, account);
      return response.copyWith(message: 'Account created successfully');
    } on FirebaseAuthException catch (createError) {
      final failure = FailureModel(
        message: 'Firebase Authentication Error during account creation',
        error: createError,
      );
      log('TestFIrebaseServices::: Error creating user: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    } catch (e) {
      final failure = FailureModel(
        message: 'An unexpected error occurred during account creation',
        error: e,
      );
      log(
        'TestFIrebaseServices::: An unexpected error occurred during account creation: ${failure.toString()}',
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<GoogleSignInAccount> google() async {
    await _googleSignIn.initialize(clientId: _webClientId);
    final GoogleSignInAccount googleAccount = await _googleSignIn
        .authenticate();

    final GoogleSignInAuthentication googleSignInAuthentication =
        googleAccount.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    return googleAccount;
  }
  //================================================================================================
  //* Add / Get / Update / Delete Data

  Future<ResponseModel> checkIsExists(
    String field,
    String collectionName,
    String search,
  ) async {
    final QuerySnapshot querySnapshot = await firestore!
        .collection(collectionName)
        .where(field, isEqualTo: search)
        .get();
    log('checkUserExists::: ${querySnapshot.docs.length}');
    if (querySnapshot.docs.isNotEmpty) {
      return ResponseModel.success(
        message: 'User exists',
        data: querySnapshot.docs.first.id,
      );
    } else {
      return ResponseModel.error(message: 'User does not exist');
    }
  }

  Future<ResponseModel> addData(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await firestore!.collection(collectionName).doc(documentId).set(data);
      return ResponseModel.success(
        message: 'Added successfully',
        data: documentId,
      );
    } catch (e) {
      final failure = FailureModel(message: 'Error adding data', error: e);
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> removeData(
    String collectionName,
    String documentId,
  ) async {
    try {
      await firestore!.collection(collectionName).doc(documentId).delete();
      log(
        'TestFIrebaseServices:::Document $documentId removed from $collectionName',
      );
      return ResponseModel.success(message: 'Data removed successfully');
    } catch (e) {
      final failure = FailureModel(message: 'Error removing data', error: e);
      log('TestFIrebaseServices:::Error removing data: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> updateData(
    String collectionName,
    String documentId,
    dynamic data,
  ) async {
    try {
      await firestore!.collection(collectionName).doc(documentId).update(data);
      log(
        'TestFIrebaseServices:::Document $documentId in $collectionName updated with $data',
      );
      return ResponseModel.success(message: 'updated successfully');
    } catch (e) {
      final failure = FailureModel(message: 'Error updating data', error: e);
      log('TestFIrebaseServices:::Error updating data: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> getUserData(
    String userId,
    String collectionName,
  ) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firestore!.collection(collectionName).doc(userId).get();

      if (documentSnapshot.exists) {
        return ResponseModel.success(
          message: 'User data retrieved successfully',
          data: documentSnapshot.data(),
        );
      } else {
        return ResponseModel.error(
          message: 'No data found for this user',
          data: null,
        );
      }
    } catch (e) {
      final failure = FailureModel(
        message: 'Error getting user data',
        error: e,
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> getAllData(String collectionName) async {
    List<Map<String, dynamic>> results = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore!
          .collection(collectionName)
          .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        results.add(doc.data());
      }
      log(
        'TestFIrebaseServices::: Successfully retrieved all data from $collectionName.',
      );
      return ResponseModel.success(
        message: 'Data retrieved successfully',
        data: results,
      );
    } catch (e) {
      final failure = FailureModel(message: 'Error getting data', error: e);
      log(
        'TestFIrebaseServices::: Error getting all data: ${failure.toString()}',
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  //================================================================================================
  //* Verification

  Future<ResponseModel> sendEmailVerification() async {
    try {
      final user = _auth!.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return ResponseModel.success(message: 'Verification email sent.');
      } else if (user != null && user.emailVerified) {
        return ResponseModel.success(message: 'Email is already verified.');
      } else {
        return ResponseModel.error(message: 'No user signed in.');
      }
    } on FirebaseAuthException catch (e) {
      final failure = FailureModel(
        message: 'Error sending verification email',
        error: e,
      );
      log(
        'TestFIrebaseServices:::Error sending verification email: ${failure.toString()}',
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    } catch (e) {
      final failure = FailureModel(
        message: 'Unexpected error sending verification email',
        error: e,
      );
      log(
        'TestFIrebaseServices:::Unexpected error sending verification email: ${failure.toString()}',
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> isEmailVerified() async {
    final user = _auth!.currentUser;
    if (user != null) {
      await user.reload(); // Ensure we have the latest verification status
      return ResponseModel.success(
        message: 'Checked email verification status.',
        data: user.emailVerified,
      );
    } else {
      return ResponseModel.error(message: 'No user signed in.', data: false);
    }
  }

  Future<ResponseModel> sendPhoneVerification(String phoneNumber) async {
    log(
      'TestFIrebaseServices:::Requesting phone verification for: $phoneNumber',
    );
    return ResponseModel.success(
      message: 'Phone verification initiated. Implement UI flow for OTP.',
    );
  }
}
