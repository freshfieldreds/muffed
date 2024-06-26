import 'dart:developer';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:logging/logging.dart';
import 'package:muffed/domain/lemmy/lemmy.dart';
import 'package:muffed/domain/lemmy_keychain/bloc.dart';
import 'package:muffed/domain/local_options/bloc.dart';
import 'package:muffed/view/router/router.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // initialize hydrated bloc
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    log(
      record.message,
      level: record.level.value,
      time: record.time,
      error: record.error,
      name: record.loggerName,
      zone: record.zone,
      stackTrace: record.stackTrace,
      sequenceNumber: record.sequenceNumber,
    );
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => LemmyKeychainBloc()),
            BlocProvider(create: (context) => LocalOptionsBloc()),
          ],
          child: BlocBuilder<LocalOptionsBloc, LocalOptionsState>(
            builder: (context, state) {
              final lightTheme = themeGenerator(
                brightness: Brightness.light,
                seedColor: state.seedColor,
              );
              final darkTheme = themeGenerator(
                brightness: Brightness.dark,
                seedColor: state.seedColor,
              );
              return RepositoryProvider(
                create: (context) => LemmyRepo(
                  lemmyKeychainBloc: context.read<LemmyKeychainBloc>(),
                ),
                child: MaterialApp.router(
                  routerConfig: routerConfig,
                  title: 'Muffed',
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: state.themeMode,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

ThemeData themeGenerator({
  required Brightness brightness,
  required Color seedColor,
}) {
  return ThemeData(
    brightness: brightness,
    colorSchemeSeed: seedColor,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
    useMaterial3: true,
  );
}
