import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muffed/app/app.dart';
import 'package:muffed/screens/home_page/home_page.dart';

import '../../global_state/bloc.dart';
import '../../repo/server_repo.dart';
import '../../screens/inbox_page/inbox_page.dart';
import '../router/router_delegate.dart';
import 'dynamic_navigation_bar.dart';

/// Initialises app providers
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GlobalBloc()),
      ],
      child: Builder(
        builder: (context) {
          return RepositoryProvider(
            create: (context) => ServerRepo(context.read<GlobalBloc>()),
            child: const _AppTheme(),
          );
        },
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView(this.lightTheme, this.darkTheme, this.themeMode);

  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  MNavigatorState get initialState => MNavigatorState(
        currentBranchIndex: 0,
        branches: [
          Branch(
            [HomePage()],
            key: GlobalKey<NavigatorState>(),
          ),
          Branch(
            [InboxPage()],
            key: GlobalKey<NavigatorState>(),
          ),
        ],
      );

  /// The navigation items, each relates to a branch
  List<DynamicNavigationItemConfig> get navigationItems => [
        const DynamicNavigationItemConfig(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        const DynamicNavigationItemConfig(
          icon: Icons.inbox_outlined,
          selectedIcon: Icons.inbox,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MNavigator(initialState),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            routerDelegate: MRouterDelegate(
              MNavigator.of(context),
            ),
            builder: (context, child) {
              return Scaffold(
                body: child,
                bottomNavigationBar: DynamicNavigationBar(navigationItems),
              );
            },
            title: 'Muffed',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
          );
        },
      ),
    );
  }
}

/// Sets up the app theme
class _AppTheme extends StatelessWidget {
  const _AppTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (previous, current) {
        if (previous.useDynamicColorScheme != current.useDynamicColorScheme) {
          return true;
        }
        if (previous.seedColor != current.seedColor) {
          return true;
        }
        if (previous.themeMode != current.themeMode) {
          return true;
        }
        if (previous.titleTextScaleFactor != current.titleTextScaleFactor) {
          return true;
        }
        if (previous.labelTextScaleFactor != current.labelTextScaleFactor) {
          return true;
        }
        if (previous.bodyTextScaleFactor != current.bodyTextScaleFactor) {
          return true;
        }
        if (previous.useDynamicColorScheme != current.useDynamicColorScheme) {
          return true;
        }
        if (previous.seedColor != current.seedColor) {
          return true;
        }
        if (previous.themeMode != current.themeMode) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ThemeData applyThemeAdjustments(ThemeData theme) {
              final textTheme = theme.textTheme;
              return theme.copyWith(
                textTheme: textTheme.apply().copyWith(
                      titleLarge: textTheme.titleLarge!.apply(
                        fontSizeFactor: state.titleTextScaleFactor,
                      ),
                      titleMedium: textTheme.titleMedium!.apply(
                        fontSizeFactor: state.titleTextScaleFactor,
                      ),
                      titleSmall: textTheme.titleSmall!.apply(
                        fontSizeFactor: state.titleTextScaleFactor,
                      ),
                      labelLarge: textTheme.labelLarge!.apply(
                        fontSizeFactor: state.labelTextScaleFactor,
                      ),
                      labelMedium: textTheme.labelMedium!.apply(
                        fontSizeFactor: state.labelTextScaleFactor,
                      ),
                      labelSmall: textTheme.labelSmall!.apply(
                        fontSizeFactor: state.labelTextScaleFactor,
                      ),
                      bodyLarge: textTheme.bodyLarge!.apply(
                        fontSizeFactor: state.bodyTextScaleFactor,
                      ),
                      bodyMedium: textTheme.bodyMedium!.apply(
                        fontSizeFactor: state.bodyTextScaleFactor,
                      ),
                      bodySmall: textTheme.bodySmall!.apply(
                        fontSizeFactor: state.bodyTextScaleFactor,
                      ),
                    ),
              );
            }

            var lightTheme = lightDynamic != null
                ? ThemeData(
                    colorScheme: lightDynamic,
                    useMaterial3: true,
                  )
                : ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: state.seedColor,
                    ),
                    useMaterial3: true,
                  );

            lightTheme = applyThemeAdjustments(lightTheme);

            var darkTheme = darkDynamic != null
                ? ThemeData(
                    colorScheme: darkDynamic,
                    useMaterial3: true,
                  )
                : ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: state.seedColor,
                      brightness: Brightness.dark,
                    ),
                    useMaterial3: true,
                  );

            darkTheme = applyThemeAdjustments(darkTheme);

            return _AppView(lightTheme, darkTheme, state.themeMode);
          },
        );
      },
    );
  }
}
