import 'package:flutter/material.dart';

void main() {
    runApp(WhatToDoApp());
}

class WhatToDoApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'What To Do App',
            theme: ThemeData(
                primarySwatch: Colors.purple,
            ),
            home: HomePage(),
        );
    }
}
