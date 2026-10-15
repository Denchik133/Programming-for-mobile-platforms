import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/auth_model.dart';
import 'models/book.dart';
import 'screens/book_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/date_picker_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_books_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reserve_screen.dart';

final AuthModel authModel = AuthModel();

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> catalogNavigatorKey =
    GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> myBooksNavigatorKey =
    GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> profileNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/catalog',
  refreshListenable: authModel,
  redirect: (context, state) {
    final isLoginRoute = state.matchedLocation == '/login';
    final isReserveRoute =
        state.matchedLocation.endsWith('/reserve');

    if (!authModel.isLoggedIn && isReserveRoute) {
      return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (authModel.isLoggedIn && isLoginRoute) {
      final from = state.uri.queryParameters['from'];
      return from ?? '/catalog';
    }

    return null;
  },
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book),
                label: 'Каталог',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark),
                label: 'Мої книги',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Профіль',
              ),
            ],
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: catalogNavigatorKey,
          routes: [
            GoRoute(
              path: '/catalog',
              builder: (context, state) {
                return CatalogScreen(
                  genre: state.uri.queryParameters['genre'],
                );
              },
              routes: [
                GoRoute(
                  path: 'book/:bookId',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId']!;
                    final book = sampleBooks.firstWhere(
                      (book) => book.id == bookId,
                      orElse: () => throw Exception('Книгу не знайдено'),
                    );

                    return BookScreen(book: book);
                  },
                  routes: [
                    GoRoute(
                      path: 'reserve',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final bookId =
                            state.pathParameters['bookId']!;
                        final book = sampleBooks.firstWhere(
                          (book) => book.id == bookId,
                        );

                        return ReserveScreen(book: book);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: myBooksNavigatorKey,
          routes: [
            GoRoute(
              path: '/my-books',
              builder: (context, state) => const MyBooksScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return LoginScreen(
          from: state.uri.queryParameters['from'],
        );
      },
    ),
    GoRoute(
      path: '/select-date',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const DatePickerScreen(),
    ),
  ],
);