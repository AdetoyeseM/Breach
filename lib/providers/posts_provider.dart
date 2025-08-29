import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final ApiService _apiService = ApiService();
  int? _selectedCategoryId;

  PostsNotifier() : super(const AsyncValue.loading()) {
    loadPosts();
  }

  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadPosts({int? categoryId}) async {
    _selectedCategoryId = categoryId;
    state = const AsyncValue.loading();
    
    try {
      final posts = await _apiService.getPosts(categoryId: categoryId);
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts(categoryId: _selectedCategoryId);
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>(
  (ref) => PostsNotifier(),
);

 
