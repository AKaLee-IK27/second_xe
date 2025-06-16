import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final Logger _logger = Logger();
  IOSink? _sink;
  File? _logFile;

  Future<void> _init() async {
    if (_logFile != null && _sink != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/app_log.txt');
    _sink = _logFile!.openWrite(mode: FileMode.append);
  }

  Future<void> logInfo(String message) async {
    await _init();
    _logger.i(message);
    _sink?.writeln('[INFO] $message');
    await _sink?.flush();
  }

  Future<void> logWarning(String message) async {
    await _init();
    _logger.w(message);
    _sink?.writeln('[WARNING] $message');
    await _sink?.flush();
  }

  Future<void> logError(String message) async {
    await _init();
    _logger.e(message);
    _sink?.writeln('[ERROR] $message');
    await _sink?.flush();
  }

  Future<String> exportAndUploadLogFile(String bucketName) async {
    await _init();
    await _sink?.flush();
    await _sink?.close();
    _sink = null; // Reopen for future logs
    final url = await StorageService.uploadFile(_logFile!, bucketName);
    // Reopen sink for continued logging
    _sink = _logFile!.openWrite(mode: FileMode.append);
    return url;
  }

  Future<void> clearLog() async {
    await _init();
    await _sink?.close();
    await _logFile?.writeAsString('');
    _sink = _logFile!.openWrite(mode: FileMode.append);
  }
}
