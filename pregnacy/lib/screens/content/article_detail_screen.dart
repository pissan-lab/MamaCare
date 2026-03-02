import 'package:flutter/material.dart';
import '../../models/health_content.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          // TODO: load article by ID from ContentService, display body + references
          child: Text('Article Detail — Coming Soon'),
        ),
      ),
    );
  }
}
