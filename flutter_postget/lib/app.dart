import 'package:flutter/material.dart';
import 'layout_desktop.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        // Adjust the theme as needed
        primarySwatch: Colors.blue,
      ),
      home: const AppStateful(),
    );
  }
}

class AppStateful extends StatefulWidget {
  const AppStateful({Key? key}) : super(key: key);

  @override
  _AppStatefulState createState() => _AppStatefulState();
}

class _AppStatefulState extends State<AppStateful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatScreen(),
    );
  }
}
