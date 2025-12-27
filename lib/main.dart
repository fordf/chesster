import 'package:chesster/screens/auth.dart';
import 'package:chesster/screens/home.dart';
import 'package:chesster/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
  runApp(Chesster());
}

class Chesster extends StatelessWidget {
  Chesster({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return MaterialApp(
      title: 'Chesster',
      // theme: ThemeData(
      //   colorScheme: colorScheme,
      //   floatingActionButtonTheme: FloatingActionButtonThemeData(
      //     backgroundColor: colorScheme.tertiary,
      //     foregroundColor: colorScheme.onTertiary,
      //   ),
      // ),
      theme: brightness == Brightness.dark
          ? MaterialTheme(TextTheme.of(context)).dark()
          : MaterialTheme(TextTheme.of(context)).light(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return const ChessHome();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const AuthScreen(
              // onSavedImageUrl: saveImageUrl,
              );
        },
      ),
    );
  }
}
