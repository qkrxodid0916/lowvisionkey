import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'utils/firebase_options.dart'; // 생성되어 있으면 주석 해제
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}