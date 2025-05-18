import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saksi_app/app/modules/news/controllers/news_controller.dart';
import 'package:saksi_app/app/modules/news/views/add_news_view.dart';
import 'package:saksi_app/app/modules/news/views/news_detail_view.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Berita',
            style: TextStyle(color: Colors.blueGrey)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueGrey),
          );
        }

        if (controller.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.newspaper, size: 80, color: Colors.blueGrey),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada berita',
                  style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddNewsView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Berita Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNews(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.news.length,
                    itemBuilder: (context, index) {
                      final newsItem = controller.news[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => NewsDetailView(news: newsItem));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (newsItem.imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    newsItem.imageUrl,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      newsItem.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(newsItem.publishedAt),
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      newsItem.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.blueGrey),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (newsItem.newsUrl.isNotEmpty)
                                          OutlinedButton.icon(
                                            onPressed: () => controller
                                                .openNewsUrl(newsItem.newsUrl),
                                            icon: const Icon(Icons.link,
                                                size: 16),
                                            label: const Text('Buka Link'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                            ),
                                          ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                  context, newsItem.id),
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          tooltip: 'Hapus Berita',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNewsView()),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String newsId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus berita ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.hardDeleteNews(newsId);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
