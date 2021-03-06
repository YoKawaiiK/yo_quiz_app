import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:yo_quiz_app/src/core/models/api_exception.dart';
import 'package:yo_quiz_app/src/core/models/unknown_exception.dart';
import 'package:yo_quiz_app/src/core/models/preview_quiz.dart';

class HomeProvider {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool _isFirstLoad = false;

  List<PreviewQuiz>? _quizzes;

  List<PreviewQuiz> get quizzes => [...?_quizzes];

  Future<String> getQuiz(String? id) async {
    try {
      if (id == null) throw ApiException("empty-field");

      final doc = await _db.collection("quizzes").doc(id).get();

      if (doc.exists) {
        await _db
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .collection("recievedQuizzes")
            .doc(doc.id)
            .set(doc.data()!);

        return doc.id;
      } else {
        throw ApiException("not-exists");
      }
    } on FirebaseException catch (e) {
      var message = "Database error";
      throw ApiException(message);
    } on ApiException catch (e) {
      var message = "Api error";

      if (e.toString() == "not-exists") {
        message = "Quiz doesn't exists.";
      } else if (e.toString() == "empty-field") {
        message = "Please insert your code";
      }

      throw ApiException(message);
    } catch (e) {
      print("getQuiz $e");
      var message = "Unknown exception";

      throw UnknownException(message);
    }
  }

  Stream<List<PreviewQuiz>> get streamAvailableQuizzes {
    return _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("recievedQuizzes")
        .orderBy("created", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {


              final previewQuiz = PreviewQuiz.fromDoc(
                _auth.currentUser!.uid,
                doc,
              );

              // previewQuiz.quizImageRef;

              // previewQuiz.quizImage = _storage.ref(previewQuiz.quizImageRef).getDownloadURL();


              return previewQuiz;
            }).toList());
  }

  // todo: use it
  Future<String?> loadQuizImage(String quizImageRef) async {
    try {
      return await _storage.ref(quizImageRef).getDownloadURL();

    } catch (e) {
      print(e);
      ApiException("Error storage.");
    }
  }

  // Future<List<AvailableQuiz>> loadAvailableQuizzes(
  //     {bool isRefresh = false}) async {
  //   try {
  //     if (_isFirstLoad && !isRefresh) return quizzes;
  //     print("refresh");

  //     final snapshot = await _db
  //         .collection("users")
  //         .doc(_auth.currentUser!.uid)
  //         .collection("recievedQuizzes")
  //         .orderBy("created", descending: true)
  //         .get();

  //     // _quizzes = [];
  //     _quizzes = snapshot.docs
  //         .map((doc) => AvailableQuiz.fromDoc(_auth.currentUser!.uid, doc))
  //         .toList();

  //     _isFirstLoad = true;

  //     return quizzes;
  //   } on FirebaseException catch (e) {
  //     var message = "Database error";
  //     throw ApiException(message);
  //   } catch (e) {
  //     print("getQuiz $e");
  //     var message = "Unknown exception";

  //     throw UnknownException(message);
  //   }
  // }

  Future<void> removeQuiz(String id) async {
    try {
      await _db
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("recievedQuizzes")
          .doc(id)
          .delete();
    } on FirebaseException catch (e) {
      var message = "Database error";
      throw ApiException(message);
    } catch (e) {
      print("getQuiz $e");
      var message = "Unknown exception";

      throw UnknownException(message);
    }
  }
}
