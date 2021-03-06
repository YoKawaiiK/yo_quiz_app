import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yo_quiz_app/src/core/router/app_router.dart';
import 'package:yo_quiz_app/src/modules/auth/provider/auth_provider.dart';
import 'package:yo_quiz_app/src/modules/create/provider/create_quiz_provider.dart';
import 'package:yo_quiz_app/src/modules/create/provider/ui_quiz_create_provider.dart';
import 'package:yo_quiz_app/src/modules/home/provider/home_provider.dart';
import 'package:yo_quiz_app/src/modules/profile/provider/created_quizzes_provider.dart';
import 'package:yo_quiz_app/src/modules/profile/provider/user_profile_provider.dart';
import 'package:yo_quiz_app/src/modules/public/provider/public_provider.dart';
import 'package:yo_quiz_app/src/modules/quiz/provider/quiz_play_provider.dart';
import 'package:yo_quiz_app/src/theme/theme.dart';

class AppQuiz extends StatelessWidget {
  const AppQuiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthProvider>(create: (_) => AuthProvider()),
        Provider<UserProfileProvider>(create: (_) => UserProfileProvider()),
        Provider<CreatedQuizzesProvider>(
            create: (_) => CreatedQuizzesProvider()),

        Provider<CreateQuizProvider>(create: (_) => CreateQuizProvider()),

        ChangeNotifierProxyProvider<CreateQuizProvider, UIQuizCreateProvider>(
            create: (context) => UIQuizCreateProvider(createQuizProvider: CreateQuizProvider()),
            update: (context, createQuiz, previousUIQuizCreate) =>
                previousUIQuizCreate!..update(createQuiz)),

        ChangeNotifierProvider<QuizPlayProvider>(
            create: (_) => QuizPlayProvider()),

        // Provider<HomeProvider>(
        //     create: (_) => HomeProvider()),
        Provider<HomeProvider>(create: (_) => HomeProvider()),

        Provider<PublicProvider>(create: (_) => PublicProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: AppRouter.routes,
        initialRoute: AppRouter.initialRoute,
        theme: messengerTheme.themeLight,
      ),
    );
  }
}
