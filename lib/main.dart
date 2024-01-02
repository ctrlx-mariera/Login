import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication.dart'; // Import of Authentication class
import 'login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              Authentication(), // Provide the Authentication class
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Sets the initial route to '/' (the login)
      routes: {
        '/': (context) =>
            const LoginPage(), // The root route, typically the login page.
      },
    );
  }
}
