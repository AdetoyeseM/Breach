import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_interest.dart';
import '../services/api_service.dart';

class UserInterestsNotifier extends StateNotifier<AsyncValue<List<UserInterest>>> {
  final ApiService _apiService = ApiService();

  UserInterestsNotifier() : super(const AsyncValue.loading());

  Future<void> loadUserInterests(int userId) async {
    state = const AsyncValue.loading();
    
    try {
      final interests = await _apiService.getUserInterests(userId);
      state = AsyncValue.data(interests);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> saveUserInterests(int userId, List<int> interests) async {
    try {
      await _apiService.saveUserInterests(interests);
      // Reload interests after saving
      await loadUserInterests(userId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearInterests() {
    state = const AsyncValue.data([]);
  }
}

final userInterestsProvider = StateNotifierProvider<UserInterestsNotifier, AsyncValue<List<UserInterest>>>(
  (ref) => UserInterestsNotifier(),
);

final selectedInterestsProvider = StateProvider<List<int>>((ref) => []);
