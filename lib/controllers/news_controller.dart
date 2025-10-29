import 'package:get/get.dart';
import 'package:news_app/models/news_articles,.dart';
import 'package:news_app/services/news_services.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  // untuk memproses request yang sudah dibuat oleh NewsServices
  final NewsServices _newsServices = NewsServices();

  // observable variables (variable yang bisa berubah)
  final _isLoading = false.obs;
  final _articles = <NewsArticles>[].obs; // untuk menampilkan daftar berita yang sudah/berhasil didapat
  final _selectedCategory = 'general'.obs; // untuk handle kategori...  pokoknya dia listnya msih kosong biar diisi sama data2 dari rest api nanti
  final _error = ''.obs; // kalo ada kesalahan, pesan error akan d....

  // getters
  // getter ini seperti jendela untuk melihat isi variable yang udh didefinisikan
  // dengan ini ui dengan mudah bisa melihat data dari controller

  bool get isLoading => _isLoading.value; // nah kalo ini isi yang tadi _isLoading = false.obs; nah bagian false bla bla itu biar kepanggil juga
  List<NewsArticles> get articles => _articles; // ini ga dikasih value karena kita ngambil data dari eksternal
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  // begitu aplikasi dibuka, aplikasi langsung menampilkan berita utama dari endpoint top headlines
  // TODO: Fetching data dari endpoint top-headlines

  // pake future karena ada proses tunggu2an
  Future<void> fetchTopHeadlines({String? category}) async {
    // blok ini akan dijalankan ketika REST API berhasil berkomunikasi dengan server
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsServices.getTopHeadLines(
        category: category ?? _selectedCategory.value,
      );

      _articles.value = response.articles;
    } catch (e) {
      _error.value  = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
      // finally akan ttp di execute setelah salah satu dari blok try atau catch sudah berhasil mendapakan hasil
    } finally {
      _isLoading.value = false;
    }
  }

  // TODO: tambahin ini agar fetchTopHeadlines bisa langsung terinisialisasi ketika aplikasi berada di home screen, khususnya ketika perpindahan dari splash screen ke home screen 

  @override 
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) return;

    try { // ini kalo sukses
      _isLoading.value = true; // ini akan membuat loading indicator muncul pertama kali saat dibuka
      _error.value = '';

      final response = await _newsServices.searchNews(query: query);
      _articles.value = response.articles;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      _isLoading.value = false; // ini biar kalo udh selesai proses ini loading indicatornya jadi hilang
    }
  }
}