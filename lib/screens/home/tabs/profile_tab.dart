// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/user_interests_provider.dart';
import '../../../models/user_interest.dart';
import '../../../models/categories.dart';
import '../../../constants/colors.dart';
import '../../auth/login_screen.dart';
import '../../../widgets/custom_text.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInterests();
    });
  }

  void _loadUserInterests() {
    final user = ref.read(userProvider);
    if (user?.userId != null) {
      ref.read(userInterestsProvider.notifier).loadUserInterests(user!.userId!);
    }
  }

  void _toggleInterest(int categoryId) {
    final currentSelected = ref.read(selectedInterestsProvider);
    final newSelected = List<int>.from(currentSelected);

    if (newSelected.contains(categoryId)) {
      newSelected.remove(categoryId);
    } else {
      newSelected.add(categoryId);
    }

    ref.read(selectedInterestsProvider.notifier).state = newSelected;
  }

  Future<void> _saveInterests() async {
    final user = ref.read(userProvider);
    if (user?.userId == null) return;

    final selectedInterests = ref.read(selectedInterestsProvider);
    await ref
        .read(userInterestsProvider.notifier)
        .saveUserInterests(user!.userId!, selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final userInterestsAsync = ref.watch(userInterestsProvider);
    final selectedInterests = ref.watch(selectedInterestsProvider);
    ref.listen<AsyncValue<List<UserInterest>>>(userInterestsProvider, (
      previous,
      next,
    ) {
      next.whenData((interests) {
        if (selectedInterests.isEmpty) {
          final interestIds =
              interests
                  .map((interest) => interest.category.id)
                  .toSet()
                  .toList();
          ref.read(selectedInterestsProvider.notifier).state = interestIds;
        }
      });
    });

    if (user == null) {
      return const Scaffold(body: Center(child: TextView(text: 'User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const TextView(text: 'Profile'),
        foregroundColor: AppColors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // User Info
                                             TextView(
                         text: 'User ID: ${user.userId ?? 'N/A'}',
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                         color: AppColors.primary,
                       ),

                      // Stats Cards
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Interests',
                              selectedInterests.length.toString(),
                              Icons.favorite,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Categories',
                              userInterestsAsync.when(
                                data:
                                    (interests) => interests.length.toString(),
                                loading: () => '...',
                                error: (_, __) => '0',
                              ),
                              Icons.category,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interests Section Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextView(
                              text: 'Your Interests',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            TextView(
                              text: 'Select topics you\'re interested in to personalize your experience',
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Interest Categories
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(categoriesProvider);

                      return categoriesAsync.when(
                        data:
                            (categories) => _buildInterestsGrid(
                              categories,
                              selectedInterests,
                              userInterestsAsync,
                            ),
                        loading:
                            () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error:
                            (_, __) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Failed to load categories',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          userInterestsAsync.isLoading ? null : _saveInterests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child:
                          userInterestsAsync.isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Save Interests',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsGrid(
    List<Categories> categories,
    List<int> selectedInterests,
    AsyncValue<List<UserInterest>> userInterestsAsync,
  ) {
    return userInterestsAsync.when(
      data:
          (userInterests) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                categories.map((category) {
                  final isSelected = selectedInterests.contains(category.id);
                  final hasUserInterest = userInterests.any(
                    (interest) => interest.category.id == category.id,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.icon ?? '📱'),
                          const SizedBox(width: 8),
                          Text(
                            category.name ?? 'Unknown',
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) => _toggleInterest(category.id!),
                      selectedColor:
                          hasUserInterest
                              ? AppColors.primary.withOpacity(0.3)
                              : AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      backgroundColor:
                          hasUserInterest
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade100,
                      side: BorderSide(
                        color:
                            hasUserInterest
                                ? AppColors.primary.withOpacity(0.5)
                                : Colors.grey.shade300,
                        width: hasUserInterest ? 2 : 1,
                      ),
                      labelStyle: TextStyle(
                        color:
                            hasUserInterest
                                ? AppColors.primary
                                : Colors.grey.shade700,
                      ),
                      avatar:
                          hasUserInterest
                              ? Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              )
                              : null,
                    ),
                  );
                }).toList(),
          ),
      loading:
          () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
      error:
          (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load interests: ${error.toString()}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
