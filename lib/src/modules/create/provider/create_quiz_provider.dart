import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:yo_quiz_app/src/core/models/api_exception.dart';
import 'package:yo_quiz_app/src/core/models/unknown_exception.dart';
import 'package:yo_quiz_app/src/modules/create/models/question.dart';
import 'package:yo_quiz_app/src/modules/create/models/quiz.dart';

class CreateQuizProvider {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  Quiz quiz = Quiz(questions: []);

  String? quizImage;
  List<Question> get questions => [...?quiz.questions];

  set title(String? title) {
    print(title);
    quiz.title = title;
  }

  String? get title => quiz.title;

  set description(String? description) {
    print(description);
    quiz.description = description;
  }

  String? get description => quiz.description;

  void cancelCreateQuiz() {
    quizImage = null;
    quiz = Quiz(questions: []);
  }

  Future<void> createQuiz() async {
    try {
      // create quiz doc
      final quizCredential = await _db.collection("quizzes").add({
        "title": quiz.title!,
        "description": quiz.description,
        "created": Timestamp.now(),
        "createdByUser": _auth.currentUser!.uid,
        "questionCount": quiz.questions!.length,
        "scope": quiz.scope.name,
        "timer": quiz.timer,
        "quizImage": null,
        "quizImageRef": null,
      });

      quiz.id = quizCredential.id;

      // ? if Quiz update then update image in another method setQuizImage
      if (quizImage != null) {
        await uploadQuizImage(isCreateQuiz: true);
      }

      // create quiz nested collection "questions"
      for (var item in quiz.questions!) {
        int rightAnswers = 0;
        for (var answer in item.answers) {
          if (answer.isRight) rightAnswers++;
        }

        await _db
            .collection("quizzes")
            .doc(quizCredential.id)
            .collection("questions")
            .doc(item.id)
            .set({
          "question": item.question,
          "secondsInTimer": item.secondsInTimer,
          "timer": item.timer,
          "answers": item.answersToListOfMap(),
          "rightAnswers": rightAnswers,
        });
      }
    } on FirebaseException catch (e) {
      var message = "Database error";

      throw ApiException(message);
    } catch (e) {
      print("createQuiz $e");

      throw UnknownException(e.toString());
    }
  }

  Future<void> updateQuiz() async {
    try {
      await _db.collection("quizzes").doc(quiz.id).update({
        "title": quiz.title!,
        "description": quiz.description,
        "created": quiz.created,
        "questionCount": quiz.questions!.length,
        "scope": quiz.scope.name,
        "timer": quiz.timer,
      });

      // todo: update question method

    } on FirebaseException catch (e) {
      var message = "Database error";
      throw ApiException(message);
    } catch (e) {
      print("updateQuiz $e");
      throw UnknownException(e.toString());
    }
  }

  Future<void> uploadQuizImage({bool isCreateQuiz = false}) async {
    // if method tries use when create quiz
    if (!isCreateQuiz && quiz.id == null) return;

    try {
      final uploadTask = await _firebaseStorage
          .ref()
          .child("quizzes")
          .child("quizImage")
          .child("${quiz.id}.jpg")
          .putFile(File(quizImage!));

      final quizImageUrl =
          await _firebaseStorage.ref(uploadTask.ref.fullPath).getDownloadURL();

      await _db.collection("quizzes").doc(quiz.id).update({
        "quizImage": quizImageUrl,
        "quizImageRef": uploadTask.ref.fullPath,
      });

      quiz.quizImageRef = uploadTask.ref.fullPath;
    } on FirebaseException catch (e) {
      var message = "Database error";

      throw ApiException(message);
    } catch (e) {
      print("createQuiz $e");

      throw UnknownException(e.toString());
    }
  }

  // will be used when user open for create quiz
  Future<void> loadQuizImage() async {
    if (quiz.quizImageRef == null) return;
    try {
      final downloadURL =
          await _firebaseStorage.ref(quiz.quizImageRef).getDownloadURL();
      quizImage = downloadURL;
    } catch (e) {
      print(e);
      throw ApiException("Error loading image.");
    }
  }

  Future<Quiz> loadQuizToEdit(String id) async {
    try {
      final quizDoc = await _db.collection("quizzes").doc(id).get();

      if (!quizDoc.exists) throw UnknownException("Quiz isn't exist.");

      final questionsSnapshot =
          await _db.collection("quizzes").doc(id).collection("questions").get();

      quiz = Quiz.fromDoc(quizDoc, questionsSnapshot);
      return quiz;
    } on FirebaseException catch (e) {
      var message = "Database error";

      throw ApiException(message);
    } catch (e) {
      print("loadQuizToEdit $e");

      throw UnknownException(e.toString());
    }
  }

  Future<void> removeQuestion(String id) async {
    try {
      final indexItem = quiz.questions!.indexWhere((item) => item.id == id);

      if (quiz.id != null && quiz.questions![indexItem].isEditted) {
        await _db
            .collection("quizzes")
            .doc(quiz.id)
            .collection("questions")
            .doc(id)
            .delete();
      }

      quiz.questions!.removeAt(indexItem);
    } on FirebaseException catch (e) {
      var message = "Database error";

      throw ApiException(message);
    } catch (e) {
      print("loadQuizToEdit $e");

      throw UnknownException(e.toString());
    }
  }

  Future<void> editQuestion(Question editedQuestion) async {
    try {
      final index = quiz.questions!
          .indexWhere((question) => question.id == editedQuestion.id);

      if (quiz.id != null && quiz.questions![index].isEditted) {
        await _db
            .collection("quizzes")
            .doc(quiz.id)
            .collection("questions")
            .doc(quiz.questions![index].id)
            .update(editedQuestion.toMap());
      }

      quiz.questions![index] = editedQuestion;
    } on FirebaseException catch (e) {
      var message = "Database error";

      throw ApiException(message);
    } catch (e) {
      print("editQuestion $e");

      throw UnknownException(e.toString());
    }
  }

  Future<void> createQuestion(Question question) async {
    try {
      quiz.questions!.add(question);

      if (quiz.id != null) {
        await _db
            .collection("quizzes")
            .doc(quiz.id)
            .collection("questions")
            .doc(question.id)
            .set(question.toMap());
      }


    } on FirebaseException catch (e) {
      var message = "Database error";

      throw ApiException(message);
    } catch (e) {
      print("createQuestion $e");

      throw UnknownException(e.toString());
    }
  }
}
