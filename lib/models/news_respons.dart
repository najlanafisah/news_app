import 'package:news_app/models/news_articles,.dart';

class NewsRespons {
  final String status;
  final int totalResults;
  final List<NewsArticles> articles;

  NewsRespons({required this.status, required this.totalResults, required this.articles});

  factory NewsRespons.fromJson(Map<String, dynamic> json) {
    return NewsRespons(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      // Kode yang digunakan untuk mengkonversi data mentah dari server
      // agar siap digunakan oleh aplikasi
      articles: (json['articles'] as List<dynamic>?)
                ?.map((article) => NewsArticles.fromJson(article))
                .toList() ?? [],
    );
  }
}