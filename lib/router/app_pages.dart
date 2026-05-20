import 'package:bujuan_music/pages/cloud/cloud_page.dart';
import 'package:bujuan_music/pages/home/today/today_page.dart';
import 'package:bujuan_music/pages/mv/mv_page.dart';
import 'package:bujuan_music/pages/play/desktop_play_page.dart';
import 'package:bujuan_music/pages/playlist/playlist_page.dart';
import 'package:bujuan_music/pages/setting/setting_page.dart';
import 'package:bujuan_music/pages/user/user_page.dart';
import 'package:bujuan_music/router/app_router.dart';
import 'package:bujuan_music/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';

class AppPages {
  static final shellRouter = [
    GoRoute(
      path: AppRouter.home,
      pageBuilder: (context, state) => NoTransitionPage(child: HomePage()),
    ),
    GoRoute(path: AppRouter.today, builder: (context, state) => TodayPage()),
    GoRoute(
        path: AppRouter.play,
        pageBuilder: (context, state) =>
            buildPageWithSlideUpTransition(state: state, child: DesktopPlayPage())),
    GoRoute(
        path: AppRouter.playlist, builder: (context, state) => PlaylistPage(state.extra as int)),
    GoRoute(
      path: AppRouter.user,
      pageBuilder: (context, state) => NoTransitionPage(child: UserPage()),
    ),
    GoRoute(
      path: AppRouter.setting,
      pageBuilder: (context, state)=>  NoTransitionPage(child: SettingPage()),
    ),
  ];

  static final rootRouter = [
    GoRoute(path: AppRouter.login, builder: (c, s) => const LoginPage()),
    GoRoute(path: AppRouter.splash, builder: (c, s) => const SplashPage()),
    GoRoute(path: AppRouter.mv, builder: (c, s) => MvPage(s.extra as int)),
    GoRoute(
      path: AppRouter.cloud,
      pageBuilder: (context, state) => NoTransitionPage(child: const CloudPage()),
    ),
  ];

  static Page<dynamic> buildPageWithSlideUpTransition({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // 从底部开始
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
