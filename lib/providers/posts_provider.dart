import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final ApiService _apiService;
  
  PostsNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadPosts({String? category}) async {
    state = const AsyncValue.loading();
    try {
      final posts = await _apiService.getPosts(category: category);
      state = AsyncValue.data(posts);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final ApiService _apiService;
  
  CategoriesNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _apiService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(ApiService());
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoriesNotifier(ApiService());
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredPostsProvider = Provider<AsyncValue<List<Post>>>((ref) {
  final postsAsync = ref.watch(postsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return postsAsync.when(
    data: (posts) {
      if (selectedCategory == null) {
        return AsyncValue.data(posts);
      }
      final filtered = posts.where((post) => post.category == selectedCategory).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
