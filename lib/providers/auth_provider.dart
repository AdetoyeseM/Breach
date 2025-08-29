import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthNotifier extends StateNotifier<AsyncValue<UserDTO?>> {
  final ApiService _apiService;
  
  AuthNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');
      
      if (userJson != null && token != null) {
        final user = UserDTO.fromJson(Map<String, dynamic>.from(
          Map<String, dynamic>.from(Map.from(json.decode(userJson)))
        ));
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveUserToStorage(UserDTO user,) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
    await prefs.setString('token', user.token ??'');
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.register(email, password);
      final user = UserDTO.fromJson(response);
    
      print("I AM THE USER ${user.toJson()}");
      await _saveUserToStorage(user);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.login(email, password);
      final user = UserDTO.fromJson(response);
     
      
      await _saveUserToStorage(user);
      state = AsyncValue.data(user);
    } catch (e) { 
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserDTO?>>((ref) {
  return AuthNotifier(ApiService());
});

final userProvider = Provider<UserDTO?>((ref) {
  return ref.watch(authProvider).value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});
