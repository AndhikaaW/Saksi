import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String newsUrl;
  final DateTime publishedAt;
  final bool isActive;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.newsUrl,
    required this.publishedAt,
    this.isActive = true,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      newsUrl: json['newsUrl'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? (json['publishedAt'] is DateTime
              ? json['publishedAt']
              : (json['publishedAt'] as Timestamp).toDate())
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'newsUrl': newsUrl,
      'publishedAt': publishedAt,
      'isActive': isActive,
    };
  }
}
