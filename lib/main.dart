import 'package:flutter/material.dart';
import 'package:mirascope/src/app/bootstrap/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await buildRootWidget());
}
