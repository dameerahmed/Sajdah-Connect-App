import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    // Android Emulator specific IP
    if (!kIsWeb && Platform.isAndroid) {
      // You can check if we are on an emulator here, 
      // but usually 10.0.2.2 is safe for all common emulators.
      // If using a physical device, 10.127.48.55 is needed.
      // return 'http://10.0.2.2:8000/api/v1'; 
    }
    return 'http://10.127.48.55:8000/api/v1';
  }
  
  static const String googleClientId = '134285546097-ngq13tpqku08o8gih2elnf3agt8739mj.apps.googleusercontent.com';
}
