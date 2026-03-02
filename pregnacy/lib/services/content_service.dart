import '../models/health_content.dart';
import '../models/content_reference.dart';
import 'api_service.dart';
import 'database_service.dart';

class ContentService {
  final ApiService _api;
  final DatabaseService _db;

  ContentService({required ApiService api, required DatabaseService db})
      : _api = api,
        _db = db;

  /// Fetch articles for a given stage, returning cached results first.
  Future<List<HealthContent>> getContentByStage(ContentStage stage) async {
    // TODO: implement cache-first logic
    throw UnimplementedError('getContentByStage not yet implemented');
  }

  /// Fetch a single article with its references.
  Future<HealthContent?> getArticleById(String id) async {
    // TODO: implement fetch + merge references
    throw UnimplementedError('getArticleById not yet implemented');
  }

  /// Returns medically reviewed content for the current pregnancy week.
  Future<HealthContent?> getWeeklyGuide({required int week}) async {
    // TODO: implement weekly guide fetch
    throw UnimplementedError('getWeeklyGuide not yet implemented');
  }

  /// Cache articles locally for offline viewing.
  Future<void> cacheArticles(List<HealthContent> articles) async {
    // TODO: implement SQLite caching
    throw UnimplementedError('cacheArticles not yet implemented');
  }
}
