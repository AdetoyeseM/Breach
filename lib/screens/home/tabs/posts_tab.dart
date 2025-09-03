import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/colors.dart';
import '../../../models/post.dart';
import '../../../providers/posts_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../post/post_detail_screen.dart';

class PostsTab extends ConsumerStatefulWidget {
  const PostsTab({super.key});

  @override
  ConsumerState<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<PostsTab> {
  int? selectedCategoryId;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load categories and posts for filtering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
      ref.read(postsProvider.notifier).loadPosts();
    });
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
    ref.read(postsProvider.notifier).loadPosts(categoryId: categoryId);
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    // Implement search functionality here
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(postsProvider.notifier).refreshPosts();
                    },
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.grey.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Filter Tabs
            categoriesAsync.when(
              data: (categories) => Container(
                height: 50,
                child: DefaultTabController(
                  length: categories.length + 1,
                  child: TabBar(
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      // All tab
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: const Text('All'),
                        ),
                      ),
                      // Category tabs
                      ...categories.map((category) => Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(category.icon ?? '📂'),
                              const SizedBox(width: 4),
                              Text(category.name ?? ''),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                    onTap: (index) {
                      if (index == 0) {
                        _filterByCategory(null);
                      } else {
                        _filterByCategory(categories[index - 1].id);
                      }
                    },
                  ),
                ),
              ),
              loading: () => const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SizedBox(
                height: 50,
                child: Center(child: Text('Failed to load categories')),
              ),
            ),

            const SizedBox(height: 16),

            // Posts List
            Expanded(
              child: postsAsync.when(
                data: (posts) => posts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: AppColors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No posts found',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(postsProvider.notifier).refreshPosts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        PostDetailScreen(post: post),
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                    reverseTransitionDuration:
                                        const Duration(milliseconds: 250),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOutCubic;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: PostCard(post: post),
                            );
                          },
                        ),
                      ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(postsProvider.notifier).refreshPosts();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Hero(
                tag: 'post_image_${post.id}',
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.grey.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.grey.withOpacity(0.1),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppColors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey.withOpacity(0.1),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Series
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.category.icon),
                          const SizedBox(width: 4),
                          Text(
                            post.category.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.series.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Content
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Author and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            post.author.name.isNotEmpty
                                ? post.author.name[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post.author.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
