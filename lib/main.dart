import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game/doodle_dash.dart';
import 'game/util/color_schemes.dart';
import 'game/widgets/game_over_overlay.dart';
import 'game/widgets/game_overlay.dart';
import 'game/widgets/main_menu_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flame',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Flame'),
    );
  }
}

final Game game = DoodleDash();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
              maxHeight: 550,
            ),
            child: GameWidget(
              game: game,
              overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
                'gameOverlay': (context, game) => GameOverlay(game),
                'mainMenuOverlay': (context, game) => MainMenuOverlay(game),
                'gameOverOverlay': (context, game) => GameOverOverlay(game),
              },
            ),
          );
        }),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
