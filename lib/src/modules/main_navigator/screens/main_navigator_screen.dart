import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:yo_quiz_app/src/modules/create/screens/create_quiz_screen.dart';
import 'package:yo_quiz_app/src/modules/main_navigator/widgets/app_bottom_navigation_bar.dart';
import 'package:yo_quiz_app/src/modules/auth/provider/auth_provider.dart';
import 'package:yo_quiz_app/src/modules/profile/screens/profile_screen.dart';

class MainNavigatorScreen extends StatefulWidget {
  static const String routeName = "/main";

  const MainNavigatorScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  late Widget _currentScreen;

  late final List<Widget?> _screenList;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );

    _screenList = [
      // Todo: add real screen here
      Center(
        child: Text("home"),
      ),
      // add item
      null,
      ProfileScreen(),
    ];

    _currentScreen = _screenList[0]!;
  }

  void _navigate(int index) {
    // add item
    if (index == 1) {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            children: [
              ListTile(
                leading: Icon(Icons.post_add),
                title: Text("Create test"),
                onTap: () {
                  Navigator.of(context).pushNamed(CreateQuizScreen.routeName);
                },
              ),
              ListTile(
                // Todo: create feature
                enabled: false,
                leading: Icon(Icons.add_link),
                title: Text("Get test by id"),
                onTap: () {
                  Navigator.of(context).pushNamed(CreateQuizScreen.routeName);
                },
              ),
            ],
          );
        },
      );
      // return;
    } else {
      setState(() {
        _currentScreen = _screenList[index]!;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticIn,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemBuilder: (_, __) {
          return _currentScreen;
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(functionNavigate: _navigate),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),

      //   onPressed: () {},
      // ),
    );
  }
}
