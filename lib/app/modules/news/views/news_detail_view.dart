import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saksi_app/app/modules/news/controllers/news_controller.dart';
import 'package:saksi_app/app/data/models/News.dart';

class NewsDetailView extends GetView<NewsController> {
  final NewsModel news;

  const NewsDetailView({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Berita',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueGrey[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty || news.imageNews.isNotEmpty)
              Stack(
                children: [
                    Hero(
                    tag: news.imageUrl,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                      ),
                      child: news.imageUrl.isNotEmpty
                      ? Image.network(
                        news.imageUrl,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                        return Image.memory(
                          Base64Decoder().convert(news.imageNews),
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 240,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey
                            ),
                          );
                          },
                        );
                        },
                      )
                      : Image.memory(
                        Base64Decoder().convert(news.imageNews),
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 240,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey
                          ),
                        );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy').format(news.publishedAt),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.blueGrey),
                          SizedBox(width: 6),
                          Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[100],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        news.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (news.newsUrl.isNotEmpty) ...[
                        Row(
                          children: const [
                            Icon(Icons.link, color: Colors.blueGrey, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Link Berita',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blueGrey.shade100),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  news.newsUrl,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    controller.openNewsUrl(news.newsUrl),
                                icon: const Icon(Icons.open_in_browser, size: 18),
                                label: const Text('Buka'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
