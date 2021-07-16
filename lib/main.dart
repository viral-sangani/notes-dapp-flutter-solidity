import 'package:flutter/material.dart';
import 'package:notetaking_dapp/controllers/note_controller.dart';
import 'package:notetaking_dapp/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteController(),
      child: MaterialApp(
        title: 'Note Taking DApp',
        theme: ThemeData.dark(),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
