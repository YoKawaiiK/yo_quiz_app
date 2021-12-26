import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yo_quiz_app/src/modules/auth/screens/auth_wrapper_screen.dart';
import 'package:yo_quiz_app/src/modules/create/provider/create_quiz_provider.dart';
import 'package:yo_quiz_app/src/modules/create/screens/create_questions_area_screen.dart';

class CreateQuizScreen extends StatefulWidget {
  static const String routeName = "/create-quiz-screen";

  CreateQuizScreen({Key? key}) : super(key: key);

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  late bool _quizHasTimer;
  File? _quizImage;

  late final GlobalKey<FormState> _form;

  @override
  void initState() {
    super.initState();

    _quizHasTimer = false;
    _form = GlobalKey<FormState>();
  }

  Future<void> _addQuizImage() async {
      final picker = ImagePicker();

      final imagePicked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (imagePicked == null) return;

      // Todo: add image provider

      setState(() {
        _quizImage = File(imagePicked.path);
      });
    }

    void _goToCreateQuestionsArea() {
      final isFormValid = _form.currentState!.validate();
      print(isFormValid);

      if (!isFormValid) return;

      _form.currentState!.save();
      // todo: save data in provider

      Navigator.of(context).pushNamed(CreateQuestionsAreaScreen.routeName);
    }

    void _closeCreateQuiz() {
      Navigator.pushReplacementNamed(context, AuthWrapper.routeName);
      Provider.of<CreateQuizProvider>(context, listen: false).cancelCreateQuiz();
    }

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context).size;

    

    

    return WillPopScope(
      onWillPop: () async {
        _closeCreateQuiz();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              onPressed: _closeCreateQuiz,
              icon: Icon(Icons.close),
            ),
            Spacer(),
            IconButton(
              onPressed: _goToCreateQuestionsArea,
              icon: Icon(Icons.list),
            ),
          ],
          // iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     IconButton(
                  //       onPressed: () {},
                  //       icon: Icon(Icons.close),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: _goToCreateQuestionsArea,
                  //       child: Text(
                  //         "Create questions",
                  //       ),
                  //     )
                  //   ],
                  // ),
                  Form(
                    key: _form,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Image for your quiz"),
                          SizedBox(
                            height: 10,
                          ),
                          // Todo: add image
                          GestureDetector(
                            onTap: () {
                              _addQuizImage();
                            },
                            child: SizedBox(
                              height: device.height * (2 / 7),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _quizImage != null
                                    ? Image.file(
                                        _quizImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: Center(
                                          child: Icon(Icons.image,
                                              size: 100,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: "Title"),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Field can not empty.";
                              if (v.length < 5 && v.length > 100)
                                return "Field can not more 100 and less 5 letters.";
    
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            minLines: 1,
                            maxLines: 10,
                            decoration: InputDecoration(labelText: "Description"),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Field can not empty.";
                              if (v.length < 5 || v.length > 200)
                                return "Field can not more 200 and less 5 letters.";
    
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // TextFormField(
                          //   keyboardType: TextInputType.number,
                          //   decoration:
                          //       InputDecoration(labelText: "Count questions"),
                          //   validator: (v) {
                          //     if (v == null || v.isEmpty)
                          //       return "Field can not empty.";
    
                          //     final questionsCount = int.parse(v);
                          //     if (questionsCount > 30)
                          //       return "Questions can be less 30.";
    
                          //     return null;
                          //   },
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.all(0),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text("Does Quiz has been timer?"),
                            value: _quizHasTimer,
                            onChanged: (v) {
                              setState(() {
                                _quizHasTimer = v!;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
