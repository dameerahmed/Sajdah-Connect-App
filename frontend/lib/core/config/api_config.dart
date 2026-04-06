import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://dameerahmed-sajdah-connect-backend.hf.space/api/v1';
    }
    // Hugging Face Public Space URL
    return 'https://dameerahmed-sajdah-connect-backend.hf.space/api/v1';
  }
  
  static const String googleClientId = '134285546097-ngq13tpqku08o8gih2elnf3agt8739mj.apps.googleusercontent.com';
}
