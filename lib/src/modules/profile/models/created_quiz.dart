import 'package:cloud_firestore/cloud_firestore.dart';

class CreatedQuiz {
  late final String id;
  late final String title;
  late final String description;
  late final int questionCount;
  late final Timestamp created;

  late final String? quizImage;
  //Scope scope;
  //bool timer;
  CreatedQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.created,
    required this.quizImage,
  });

  CreatedQuiz.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {

    id = doc.id;
    final data = doc.data()!;

    title = data["title"];
    description = data["description"];
    questionCount = data["questionCount"];
    created = data["created"];

    quizImage = data["quizImage"];

  }
}
