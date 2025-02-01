import 'dart:ui';

import 'package:course_loading_system/pages/conflict_detection.dart';
import 'package:course_loading_system/pages/course_scheduling.dart';
import 'package:course_loading_system/pages/dashboard.dart';
import 'package:course_loading_system/pages/instructor_mgt.dart';
import 'package:course_loading_system/pages/login_page.dart';
import 'package:course_loading_system/pages/register_page.dart';
import 'package:course_loading_system/pages/reports.dart';
import 'package:course_loading_system/security/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'constants.dart';

import 'data/providers.dart';
import 'firebase_options.dart';


Future<void> main() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print("Notification permission: ${settings.authorizationStatus}");
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





  late final _router = GoRouter(
    initialLocation: '/login',
    redirect: _appRedirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return DashboardScreen(
            changeTheme: changeThemeMode,
            changeColor: changeColor,
            colorSelected: colorSelected,
          );
        },
      ),
      GoRoute(
        path: '/instructor',
        builder: (context, state) {
          return InstructorMgt(
            changeTheme: changeThemeMode,
            changeColor: changeColor,
            colorSelected: colorSelected,
          );
        },
      ),
      GoRoute(
        path: '/scheduling',
        builder: (context, state) => CourseSchedulingScreen(),
      ),
      GoRoute(
        path: '/conflicts',
        builder: (context, state) => ConflictDetectionScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => ReportsScreen(),
      ),
    ],
    errorPageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Text(state.error.toString()),
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

    else if (loggedIn && isOnLoginPage) {
      return '/dashboard';

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