import 'dart:ui';

import 'package:course_loading_system/pages/login_page.dart';
import 'package:course_loading_system/pages/register_page.dart';
import 'package:course_loading_system/security/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'constants.dart';

import 'data/providers.dart';
import 'firebase_options.dart';
import 'home.dart';

Future<void> main() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(child:   LoadingApp())


  );

}


class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad
  };
}

class LoadingApp extends ConsumerStatefulWidget {
  const LoadingApp({super.key});

  @override
  ConsumerState<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends ConsumerState<LoadingApp> {
  ThemeMode themeMode = ThemeMode.light;
  ColorSelection colorSelected = ColorSelection.blue;

  /// Authentication to manage user login session

  final YummyAuth _auth = YummyAuth();



  late final _router = GoRouter(
    initialLocation: '/login',
    redirect: _appRedirect,
    routes: [
      GoRoute(
          path: '/login',
          builder: (context, state) {
          return  LoginPage(
              // onLogIn: (Credentials credentials) async {
              //   _auth
              //       .signIn(credentials.username, credentials.password)
              //       .then((_) => context.go('/${YummyTab.home.value}'));
              // }
            );

          },




      ),
      GoRoute(
          path: '/register',
          builder: (context, state) =>
              RegisterPage()

      ),

      GoRoute(
          path: '/:tab',
          builder: (context, state) {
            return Home(
                auth: _auth,
                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,
                tab: int.tryParse(
                    state.pathParameters['tab'] ?? '') ?? 0);
          },


      ),






    ],
    errorPageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Text(
              state.error.toString(),
            ),
          ),
        ),
      );
    },
  );

  Future<String?> _appRedirect(

      BuildContext context, GoRouterState state) async {
    final userDao = ref.watch(userDaoProvider);
    final loggedIn=userDao.isLoggedIn();


   // final loggedIn = await _auth.loggedIn;
    final isOnLoginPage = state.matchedLocation == '/login';


    // Go to /login if the user is not signed in
    if (!loggedIn) {
      return '/login';
    }
    // Go to root of app / if the user is already signed in
    else if (loggedIn && isOnLoginPage) {
      return '/0}';
     // return '/login';
    }

    // no redirect
    return null;
  }

  void changeThemeMode(bool useLightMode) {
    setState(() {
      themeMode = useLightMode
          ? ThemeMode.light //
          : ThemeMode.dark;
    });
  }

  void changeColor(int value) {
    setState(() {
      colorSelected = ColorSelection.values[value];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      scrollBehavior: CustomScrollBehavior(),
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}