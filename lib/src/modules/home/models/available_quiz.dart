import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yo_quiz_app/src/core/enums/scope.dart';

class AvailableQuiz {
  late final String id;

  late final Timestamp created;
  late final String createdByUser;
  late final String title;
  late final String description;
  late final int questionCount;
  late final String? quizImage;
  late final Scope scope;
  late final bool timer;

  late final bool isUserOwnQuiz;

  AvailableQuiz.fromDoc(uid, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    id = doc.id;

    final data = doc.data();

    created = data["created"];
    createdByUser = data["createdByUser"];
    title = data["title"];
    description = data["description"];
    questionCount = data["questionCount"];
    quizImage = data["quizImage"];
    scope = Scopes.fromString(data["scope"]);
    timer = data["timer"];

    isUserOwnQuiz = (uid == createdByUser);
    
  }
}
