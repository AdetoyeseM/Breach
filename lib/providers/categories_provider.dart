import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/categories.dart';
import '../services/api_service.dart';

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Categories>>> {
  final ApiService _apiService = ApiService();
  
  CategoriesNotifier() : super(const AsyncValue.loading());

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

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Categories>>>((ref) {
  return CategoriesNotifier();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
