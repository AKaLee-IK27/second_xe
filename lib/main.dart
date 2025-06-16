import 'package:flutter/material.dart';
import 'package:second_xe/app.dart';
import 'core/services/supabase_service.dart';
import 'core/services/log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize LogService and write a startup log
  await LogService().logInfo('App started');

  runApp(const MyApp());
}
