import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yo_quiz_app/src/core/widgets/modal_bottom_navigation.dart';
import 'package:yo_quiz_app/src/core/widgets/quiz_card.dart';
import 'package:yo_quiz_app/src/core/widgets/quiz_image.dart';
import 'package:yo_quiz_app/src/modules/home/models/available_quiz.dart';
import 'package:yo_quiz_app/src/modules/home/provider/home_provider.dart';
import 'package:yo_quiz_app/src/modules/quiz/screens/quiz_main_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";
  HomeScreen({Key? key}) : super(key: key);

  // var _scaffoldkey = GlobalKey<ScaffoldState>();

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => ModalBottomNavigation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final homeProvider = Provider.of<HomeProvider>;

    return Scaffold(
      // appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () => homeProvider(context, listen: false)
            .loadAvailableQuizzes(isRefresh: true),
        child: SafeArea(


          child: StreamBuilder<List<AvailableQuiz>>(
              // stream:
              //     homeProvider(context).loadAvailableQuizzes(),
              stream:
                  homeProvider(context).streamAvailableQuizzes,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Icon(
                      Icons.error,
                      size: 200,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 200,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }

                final quizzes = snapshot.data!;
                print(quizzes.length);

                return ListView.separated(
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                  itemCount: quizzes.length,
                  itemBuilder: (_, i) {
                    final quiz = quizzes[i];
                    return QuizCard(quiz: quiz);
                  },
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenu(context),
        child: Icon(Icons.quiz),
      ),
    );
  }
}
