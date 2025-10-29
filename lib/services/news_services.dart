import 'dart:convert';
import 'package:news_app/models/news_respons.dart';
import 'package:news_app/utils/constants.dart';
// mendfinisikan sebuah package/library menjadi sebuah variable secara langsung 
import 'package:http/http.dart' as http;

class NewsServices {
  static const String _baseUrl = Constants.baseUrl;
  static final String _apiKey = Constants.apiKey;

  // FUngsi yang bertujuan untuk membuat request GET ke server
  Future<NewsResponse> getTopHeadLines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = 20
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'country': country,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      // statement yang akan dijalankan ketika category tidak kosong
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      // berfungsi untuk parsing data dari json ke ui
      // simplenya kita daftarin baseUrl + endpoint yang akan digunakan
      final uri = Uri.parse('$_baseUrl${Constants.topHeadlines}')
          .replace(queryParameters: queryParams);
      
      // untuk menyimpan respon yang diberikan oleh server
      final response = await http.get(uri);

      // kode yang akan dijalankan jika request ke API sukses
      if (response.statusCode == 200) {
        // untuk mengubah data dari json ke bahasa dart
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      // kode yang akan dijalankan jika requst ke API gagal atau status HTTP != 200
      } else {
        throw Exception('Failed to load news, please try again later.');
      }
      // kode dijalankan ketika error lain, selain yang sudah diatas
      // e = error
    } catch (e) {
      throw Exception('Another problem occurs, please try again later.');
    }
  }

  Future<NewsResponse> searchNews({
    required String query, // ini adlaah nilai yang dimasukkan ke kolom pencarian
    int page = 1, // ini untuk mendefinisikan halaman berita ke berapa
    int pageSize = 20, // berapa banyak berita yang ingin ditampilkan ketika sekali roses rendering/memuat data
    String? sortBy,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString()
      };

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      final uri = Uri.parse('$_baseUrl${(Constants.everything)}')
            .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load news, please try again later.');
      }

    } catch (e) {
      throw Exception('Another problem occurs, please try again later.');
    }
  }
}