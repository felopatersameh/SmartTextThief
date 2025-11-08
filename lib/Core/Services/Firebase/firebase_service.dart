import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../Utils/Enums/collection_key.dart';
import 'response_model.dart';
import 'failure_model.dart';

// Comment out all log statements to disable logging

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
      // log(e.toString());
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
      // log('TestFIrebaseServices::: Error creating user: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    } catch (e) {
      final failure = FailureModel(
        message: 'An unexpected error occurred during account creation',
        error: e,
      );
      // log(
      //   'TestFIrebaseServices::: An unexpected error occurred during account creation: ${failure.toString()}',
      // );
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

  Future<void> logOut() async {
    await _auth?.signOut();
    await _googleSignIn.signOut();
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
    // log('checkUserExists::: ${querySnapshot.docs.length}');
    if (querySnapshot.docs.isNotEmpty) {
      return ResponseModel.success(
        message: 'exists',
        data: querySnapshot.docs.first.id,
      );
    } else {
      return ResponseModel.error(message: 'does not exist');
    }
  }

  Future<ResponseModel> addData(
    String mainCollectionName,
    String mainDocumentId,
    Map<String, dynamic> data, {
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      // Start with the DocumentReference to the main collection and the provided documentId
      DocumentReference docRef = firestore!
          .collection(mainCollectionName)
          .doc(mainDocumentId);

      // If subCollections are provided, traverse into them one by one
      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final subCollection = subCollections[i];
          final subId = (subIds != null && subIds.length > i)
              ? subIds[i]
              : null;

          // Get the CollectionReference under the current docRef
          final CollectionReference colRef = docRef.collection(subCollection);

          // If a subId is provided, use it; otherwise, generate a new doc
          docRef = (subId != null && subId.isNotEmpty)
              ? colRef.doc(subId)
              : colRef.doc();
        }
      }

      // Write the data to the final docRef (either the main document or within a subCollections)
      await docRef.set(data);

      // Return the main documentId as requested
      return ResponseModel.success(
        message: 'Data added successfully',
        data: mainDocumentId,
      );
    } catch (e) {
      final failure = FailureModel(message: 'Error adding data', error: e);
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> removeData(
    String mainCollectionName,
    String documentId, {
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      DocumentReference docRef = firestore!
          .collection(mainCollectionName)
          .doc(documentId);

      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final subCollection = subCollections[i];
          final subId = (subIds != null && subIds.length > i)
              ? subIds[i]
              : null;
          final CollectionReference colRef = docRef.collection(subCollection);
          docRef = (subId != null && subId.isNotEmpty)
              ? colRef.doc(subId)
              : colRef.doc();
        }
      }

      await docRef.delete();
      // log('TestFirebaseServices:::Document $documentId removed from $mainCollectionName');
      return ResponseModel.success(message: 'Data removed successfully');
    } catch (e) {
      final failure = FailureModel(message: 'Error removing data', error: e);
      // log('TestFirebaseServices:::Error removing data: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> updateData(
    String mainCollectionName,
    String documentId,
    Map<String, dynamic> data, {
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      DocumentReference docRef = firestore!
          .collection(mainCollectionName)
          .doc(documentId);

      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final subCollection = subCollections[i];
          final subId = (subIds != null && subIds.length > i)
              ? subIds[i]
              : null;
          final CollectionReference colRef = docRef.collection(subCollection);

          docRef = (subId != null && subId.isNotEmpty)
              ? colRef.doc(subId)
              : colRef.doc();
        }
      }

      // log('updateData:: Updating document at path: ${docRef.path} with data: $data');
      await docRef.update(data);
      // log('updateData:: Document updated successfully');

      return ResponseModel.success(message: 'Updated successfully');
    } catch (e) {
      final failure = FailureModel(message: 'Error updating data', error: e);
      // log('updateData:: Error updating data: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> getData(
    String documentId,
    String mainCollectionName, {
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      DocumentReference docRef = firestore!
          .collection(mainCollectionName)
          .doc(documentId);

      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final subCollection = subCollections[i];
          final subId = (subIds != null && subIds.length > i)
              ? subIds[i]
              : null;
          final CollectionReference colRef = docRef.collection(subCollection);
          docRef = (subId != null && subId.isNotEmpty)
              ? colRef.doc(subId)
              : colRef.doc();
        }
      }

      final documentSnapshot = await docRef.get();

      if (documentSnapshot.exists) {
        return ResponseModel.success(
          message: 'Data retrieved successfully',
          data: documentSnapshot.data(),
        );
      } else {
        return ResponseModel.error(message: 'No data found', data: null);
      }
    } catch (e) {
      final failure = FailureModel(message: 'Error getting data', error: e);
      // log('TestFirebaseServices:::Error getting data: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> getAllData(
    String mainCollectionName,
    String documentId, {
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      // Always start from the main document
      DocumentReference<Map<String, dynamic>> docRef = firestore!
          .collection(mainCollectionName)
          .doc(documentId);

      // Initialize targetCollection with a default value (to satisfy null safety)
      CollectionReference<Map<String, dynamic>> targetCollection = docRef
          .collection(mainCollectionName);

      // If there are subCollections, traverse until the last one
      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final subCollection = subCollections[i];
          final subId = (subIds != null && subIds.length > i)
              ? subIds[i]
              : null;

          final currentCollection = docRef.collection(subCollection);

          if (i == subCollections.length - 1) {
            // The last collection is the one we’ll get all docs from
            targetCollection = currentCollection;
          }

          if (subId != null && subId.isNotEmpty) {
            docRef = currentCollection.doc(subId);
          }
        }
      } else {
        // No subCollections, so get all documents directly under the main document
        targetCollection = docRef.collection(mainCollectionName);
      }

      // Fetch all documents from the target collection
      final querySnapshot = await targetCollection.get();

      final results = querySnapshot.docs.map((doc) => doc.data()).toList();

      // log('TestFirebaseServices::: Successfully retrieved all data from $mainCollectionName/$documentId');
      // log('results::: $results');
      return ResponseModel.success(
        message: 'Data retrieved successfully',
        data: results,
      );
    } catch (e) {
      final failure = FailureModel(message: 'Error getting data', error: e);
      // log('TestFirebaseServices::: Error getting all data: ${failure.toString()}');
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  /// Generic query helpers by email field for any collection
  Future<ResponseModel> findDocsByField(
    String collectionName,
    String field, {
    String nameField = 'id',
    int? limit,
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      CollectionReference<Map<String, dynamic>> ref = firestore!.collection(
        collectionName,
      );
      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final id = (subIds != null && subIds.length > i) ? subIds[i] : null;
          ref = id != null
              ? ref.doc(id).collection(subCollections[i])
              : ref.doc(subCollections[i]).collection(subCollections[i]);
        }
      }
      Query<Map<String, dynamic>> query = ref.where(
        nameField,
        isEqualTo: field,
      );
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      final List<Map<String, dynamic>> results = snapshot.docs
          .map((d) => d.data())
          .toList();
      return ResponseModel.success(
        message: results.isEmpty
            ? 'No documents found for $field in $collectionName'
            : 'Found ${results.length} documents',
        data: results,
      );
    } catch (e) {
      final failure = FailureModel(
        message: 'Error querying $collectionName by $nameField',
        error: e,
      );
      return ResponseModel.error(message: failure.message, failure: failure);
    }
  }

  Future<ResponseModel> findDocsInList(
    String collectionName,
    String field, {
    String nameField = '',
    int? limit,
    List<String>? subCollections,
    List<String>? subIds,
  }) async {
    try {
      CollectionReference<Map<String, dynamic>> ref = firestore!.collection(
        collectionName,
      );
      if (subCollections != null && subCollections.isNotEmpty) {
        for (int i = 0; i < subCollections.length; i++) {
          final id = (subIds != null && subIds.length > i) ? subIds[i] : null;
          ref = id != null
              ? ref.doc(id).collection(subCollections[i])
              : ref.doc(subCollections[i]).collection(subCollections[i]);
        }
      }
      Query<Map<String, dynamic>> query = ref.where(
        nameField,
        arrayContains: field,
      );
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      final List<Map<String, dynamic>> results = snapshot.docs
          .map((d) => d.data())
          .toList();
      return ResponseModel.success(
        message: results.isEmpty
            ? 'No documents found for $field in $collectionName'
            : 'Found ${results.length} documents',
        data: results,
      );
    } catch (e) {
      final failure = FailureModel(
        message: 'Error querying $collectionName by $nameField',
        error: e,
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
      // log(
      //   'TestFIrebaseServices:::Error sending verification email: ${failure.toString()}',
      // );
      return ResponseModel.error(message: failure.message, failure: failure);
    } catch (e) {
      final failure = FailureModel(
        message: 'Unexpected error sending verification email',
        error: e,
      );
      // log(
      //   'TestFIrebaseServices:::Unexpected error sending verification email: ${failure.toString()}',
      // );
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
    // log(
    //   'TestFIrebaseServices:::Requesting phone verification for: $phoneNumber',
    // );
    return ResponseModel.success(
      message: 'Phone verification initiated. Implement UI flow for OTP.',
    );
  }

  //================================================================================================
}

Map<String, dynamic> calculateGpaWithLevel(
  List<num> degree,
  List<num> realDegree,
) {
  if (degree.isEmpty ||
      realDegree.isEmpty ||
      degree.length != realDegree.length) {
    return {"gpa": 0.0, "level": "No Data"};
  }

  final num totalGot = degree.reduce((a, b) => a + b);
  final num totalPossible = realDegree.reduce((a, b) => a + b);

  if (totalPossible == 0) return {"gpa": 0.0, "level": "No Data"};

  final double percentage = (totalGot / totalPossible) * 100;

  final double gpa = _convertToGradePoint(percentage);

  final String level = _getLevelByGpa(gpa);

  return {"gpa": double.parse(gpa.toStringAsFixed(2)), "level": level};
}

double _convertToGradePoint(double percentage) {
  if (percentage >= 93) return 4.0;
  if (percentage >= 90) return 3.7;
  if (percentage >= 87) return 3.3;
  if (percentage >= 83) return 3.0;
  if (percentage >= 80) return 2.7;
  if (percentage >= 77) return 2.3;
  if (percentage >= 73) return 2.0;
  if (percentage >= 70) return 1.7;
  if (percentage >= 67) return 1.3;
  if (percentage >= 65) return 1.0;
  return 0.0;
}

String _getLevelByGpa(double gpa) {
  if (gpa >= 3.7) return "Excellent";
  if (gpa >= 3.3) return "Very Good";
  if (gpa >= 2.7) return "Good";
  if (gpa >= 2.0) return "Fair";
  if (gpa >= 1.0) return "Poor";
  return "Fail";
}
