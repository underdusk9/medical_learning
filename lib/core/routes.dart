import 'package:go_router/go_router.dart';
import 'constants.dart';
import '../screens/home_screen.dart';
import '../screens/filter_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/bookmark_list_screen.dart';
import '../screens/note_list_screen.dart';
import '../screens/note_edit_screen.dart';
import '../screens/random_setup_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/changelog_screen.dart';

/// GoRouter 路由表定义
final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeHome,
  routes: [
    GoRoute(
      path: AppConstants.routeHome,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppConstants.routeFilter,
      name: 'filter',
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      path: AppConstants.routeQuiz,
      name: 'quiz',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return QuizScreen(
          questionIds: extra['questionIds'] as List<int>? ?? [],
          sessionType: extra['sessionType'] as String? ?? 'filter',
        );
      },
    ),
    GoRoute(
      path: AppConstants.routeBookmarkList,
      name: 'bookmarks',
      builder: (context, state) => const BookmarkListScreen(),
    ),
    GoRoute(
      path: AppConstants.routeNoteList,
      name: 'notes',
      builder: (context, state) => const NoteListScreen(),
    ),
    GoRoute(
      path: AppConstants.routeNoteEdit,
      name: 'noteEdit',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return NoteEditScreen(
          questionId: extra['questionId'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: AppConstants.routeRandomSetup,
      name: 'randomSetup',
      builder: (context, state) => const RandomSetupScreen(),
    ),
    GoRoute(
      path: AppConstants.routeSettings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppConstants.routeChangelog,
      name: 'changelog',
      builder: (context, state) => const ChangelogScreen(),
    ),
  ],
);
