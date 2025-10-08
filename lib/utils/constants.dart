import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String baseUrl = 'https://newsapi.org/v2/';

  // Get API KEY from env variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // List of endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';
}