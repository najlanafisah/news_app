import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_articles,.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsDetailScreen  extends StatelessWidget {
  final NewsArticles article = Get.arguments as NewsArticles;

  NewsDetailScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView( // kalo pake ini jadi lebih bebas dibanding SingleChildScrollView
        slivers: [ 
          SliverAppBar( // ini bikin app barnya jadi lebih bagus (transparant)
            expandedHeight: 300,
            pinned: true, // kalo di scroll appbarnya ttp ada
            flexibleSpace: FlexibleSpaceBar(
              background: article.urlToImage != null
                  ? CachedNetworkImage( // Ini bakal bikin semua size gambarnya sama, karaena biasanya beda2, jadi disamain
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover, // agar menutupi seluruh bagian dari appbar
                      placeholder: (context, url) => Container(
                        color: AppColors.divider,
                        child: Center(
                          child: CircularProgressIndicator(), // untuk loading kalo belom muncul gambarnya
                        ),
                      ),

                      errorWidget: (context, url, error) => Container( // ini kalo gambarnya ga support png dan jpg (misal dia svg dll) bakal muncul icon ini
                        color: AppColors.divider,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: AppColors.textHint,
                          ),
                      ),
                  )
                  
                : Container( // satement yang akan dijalankan ketika server tidak memiliki gambar/imaage == null
                  color: AppColors.divider,
                  child: Icon(
                    Icons.newspaper,
                    size: 50,
                    color: AppColors.textHint
                  ),
                )
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                ),
                onPressed: () => _shareArticle(),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'copy_link':
                      _copyLink();
                      break;
                    case 'open_browser':
                      _openInBrowser();
                    break;
                  }
                },
                itemBuilder: (context) => [  // ini yang nanti muncul dropdown copy link dan open browser
                  PopupMenuItem(
                    value: 'copy_link',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copy Link')
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'open_browser',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser),
                        SizedBox(width: 8),  // ini bisa jadi error
                        Text('Open in Browser')
                      ],
                    ),
                  )                ],
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // source and date
                  Row(
                    children: [
                      if (article.source?.name != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            article.source!.name!,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                      if (article.publishedAt != null) ...[
                        Text(
                          timeago.format(DateTime.parse(article.publishedAt!)),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12
                          )
                        )
                      ]
                    ]
                  ),
                  SizedBox(height: 16),

                  // title
                  if (article.title != null) ...[
                    Text(
                      article.title!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3
                      ),
                    ),
                    SizedBox(height: 16)
                  ],

                  // description
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5
                      ),
                    )
                  ],
                  SizedBox(height: 20),

                  // Content
                  if (article.content != null) ...[
                    Text(
                      'Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      article.content!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.6
                      ),
                    ),
                    SizedBox(height: 24), // untuk jarak antara konten ke button
                  ],

                  // Read full article button
                  if (article.url != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openInBrowser,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          )
                        ),
                        child: Text(
                          'Read Full Article',
                          style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                      ),
                    )
                  ],
                  SizedBox(height: 32)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _copyLink() {
    if (article.url != null) {
      Clipboard.setData(ClipboardData(text: article.url!)); // clipBoard berguna saat user mengcopy
      Get.snackbar(
        'Success',
        'Link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2)
      );
    }
  }

  void _openInBrowser() async {
    if (article.url != null) {
      final Uri url = Uri.parse(article.url!);
      // proses menunggu apakah url valid dna bisa dibuka oleh browser
      if (await canLaunchUrl(url)) {
        // proses menunggu ketia url sudah valid dan sedang di proses oleh browser sampai datanya muncul
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          "Couldn't open the link",
          snackPosition: SnackPosition.BOTTOM
        );
      }
    }
  }

  void _shareArticle() {
    if (article.url != null) {
      Share.share(
        '${article.title ?? 'Check out these news'}\n\n${article.url!}', // string interpoletion  ini biar dia kepanggil title dan urlnya
        subject: article.title,
      );
    }
  }
}