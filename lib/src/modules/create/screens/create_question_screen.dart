import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:yo_quiz_app/src/modules/create/models/answer.dart';
import 'package:yo_quiz_app/src/modules/create/models/question.dart';
import 'package:yo_quiz_app/src/modules/create/models/question_create_errors.dart';
import 'package:yo_quiz_app/src/modules/create/provider/create_quiz_provider.dart';
import 'package:yo_quiz_app/src/modules/create/provider/ui_quiz_create_provider.dart';

import '../constants/constants.dart' as constants;

class CreateQuestionScreen extends StatefulWidget {
  static const String routeName = "/create-question";

  CreateQuestionScreen({Key? key}) : super(key: key);

  @override
  _CreateQuestionScreenState createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  late final GlobalKey<FormState> _form;

  late bool _questionHasTimer;
  int? _secondsInTimer;
  String? _question;
  late List<Answer> _answers;
  String? _uid;

  late bool _isQuestionEdit;

  late bool _isUpload;
  late bool _isEditted;

  @override
  void initState() {
    _form = GlobalKey<FormState>();
    _questionHasTimer = false;
    _answers = [];
    _isQuestionEdit = false;
    _isUpload = false;
    _isEditted = false;

    super.initState();
  }

  void _editQuestionInit(String id) {
    // for only one initialization
    if (_uid != null) return;

    final question = Provider.of<UIQuizCreateProvider>(context, listen: false)
        .createQuizProvider
        .quiz
        .questions!
        .firstWhere((item) => item.id == id);

    if (question.timer) {
      _questionHasTimer = question.timer;
      _secondsInTimer = question.secondsInTimer;
    }

    _uid = question.id;
    _question = question.question;
    _answers = question.answers;
    _isEditted = true;
  }

  void _addAnswer() {
    if (_answers.length == constants.MAX_ANSWERS_COUNT) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No more 10 answers")));
    } else {
      setState(() {
        _answers.add(Answer(id: Uuid().v1()));
      });
    }
  }

  void _toggleAnswer(int index) {
    setState(() {
      _answers[index].isRight = !_answers[index].isRight;
    });
  }

  void _removeAnswer(String id) {
    setState(() {
      _answers.removeWhere((answer) => answer.id == id);
    });
  }

  bool _isFormValid() {
    QuestionCreateErrors questionCreateError = QuestionCreateErrors();

    if (!_form.currentState!.validate()) return false;

    if (_answers.isEmpty)
      questionCreateError.add("Question must has minimum 1 answer.");

    if (questionCreateError.errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(questionCreateError.toString())));
      return false;
    } else {
      return true;
    }
  }

  void _createQuestion() {
    if (!_isFormValid()) return;

    setState(() {
      _isUpload = true;
    });

    _form.currentState!.save();

    // if question editted or new
    final idQuestion = _isQuestionEdit ? _uid : Uuid().v1();

    final question = Question(
      id: idQuestion!,
      question: _question!,
      answers: _answers,
      timer: _questionHasTimer,
      secondsInTimer: _secondsInTimer,
    );

    if (_isQuestionEdit) {
      Provider.of<UIQuizCreateProvider>(context, listen: false)
          .editQuestion(question);
    } else {
      Provider.of<UIQuizCreateProvider>(context, listen: false)
          .addQuestion(question);
    }
    _goBackToCreateQuestionsArea();

    setState(() {
      _isUpload = false;
    });
  }

  void _goBackToCreateQuestionsArea() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _removeQuestion() {
    _goBackToCreateQuestionsArea();
    Provider.of<UIQuizCreateProvider>(context, listen: false)
        .removeQuestion(_uid!);
  }

  Future<void> _updateQuestion() async {
    try {
      setState(() {
        _isUpload = true;
      });
      final uIQuizCreateProvider =
          Provider.of<UIQuizCreateProvider>(context, listen: false);

      final idQuestion = _isQuestionEdit ? _uid : Uuid().v1();

      final question = Question(
        id: idQuestion!,
        question: _question!,
        answers: _answers,
        timer: _questionHasTimer,
        secondsInTimer: _secondsInTimer,
        isEditted: _isUpload,
      );

      await uIQuizCreateProvider.editQuestion(question);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isUpload = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String?;

    if (id != null) {
      _isQuestionEdit = true;

      _editQuestionInit(id);
    }

    return WillPopScope(
      onWillPop: () async {
        _goBackToCreateQuestionsArea();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          actions: [
            Spacer(),
            if (_isQuestionEdit)
              IconButton(
                onPressed: _removeQuestion,
                icon: Icon(
                  Icons.delete_forever,
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _form,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _question,
                        onChanged: (v) {
                          _question = v;
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "Question must be fill.";
                          return null;
                        },
                        decoration: InputDecoration(labelText: "Question text"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // CheckboxListTile(
                      //   contentPadding: EdgeInsets.all(0),
                      //   controlAffinity: ListTileControlAffinity.leading,
                      //   title: Text("Is this question has timer?"),
                      //   value: _questionHasTimer,
                      //   onChanged: (v) {
                      //     setState(() {
                      //       _questionHasTimer = v!;
                      //     });
                      //   },
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      // AnimatedSwitcher(
                      //   duration: Duration(milliseconds: 300),
                      //   child: _questionHasTimer
                      //       ? Column(
                      //           children: [
                      //             TextFormField(
                      //               initialValue: _secondsInTimer == null
                      //                   ? ""
                      //                   : _secondsInTimer.toString(),
                      //               onChanged: (v) {
                      //                 _secondsInTimer = int.parse(v);
                      //               },
                      //               keyboardType: TextInputType.number,
                      //               decoration: InputDecoration(
                      //                   labelText: "Seconds in timer"),
                      //               validator: (v) {
                      //                 // todo: implementation validator for int
                      //                 return null;
                      //               },
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //           ],
                      //         )
                      //       : SizedBox(
                      //           height: 0,
                      //         ),
                      // ),

                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _answers.length,
                        // physics: ScrollPhysics(),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) => Container(
                          key: Key(_answers[i].id),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            initialValue: _answers[i].text,
                            onChanged: (v) {
                              _answers[i].text = v;
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Answer must be fill.";
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Write this your answer $i",
                              suffixIcon: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      color: _answers[i].isRight
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      icon: _answers[i].isRight
                                          ? Icon(Icons.check)
                                          : Icon(Icons.close),
                                      onPressed: () {
                                        _toggleAnswer(i);
                                      },
                                    ),
                                    IconButton(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _removeAnswer(_answers[i].id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _addAnswer,
                            child: Text(
                              "Add Answer",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .fontSize,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _isQuestionEdit
                                ? (_isUpload ? null : _updateQuestion)
                                : _createQuestion,
                            child: _isUpload
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    _isQuestionEdit
                                        ? "Update question"
                                        : "Create question",
                                    style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .fontSize,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _addAnswer,
        //   child: Icon(Icons.question_answer),
        // ),
      ),
    );
  }
}
