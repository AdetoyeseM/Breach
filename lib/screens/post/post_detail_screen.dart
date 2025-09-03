import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/colors.dart';
import '../../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> toolbarCollapsed = ValueNotifier(false);
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      body: Container(
        color: Colors.transparent,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              // backgroundColor: AppColors.white,
              iconTheme: IconThemeData(
                color: toolbarCollapsed.value ? Colors.black : Colors.white,
              ),

              flexibleSpace: LayoutBuilder(
                builder: (context, constraint) {
                  toolbarCollapsed.value = constraint.maxHeight < 105;
                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    titlePadding: const EdgeInsets.symmetric(horizontal: 50),
                    stretchModes: const [
                      StretchMode.fadeTitle,
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Hero(
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
                                        placeholder:
                                            (context, url) => Container(
                                              color: AppColors.grey.withOpacity(
                                                0.1,
                                              ),
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.white),
                                                ),
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Container(
                                              color: AppColors.grey.withOpacity(
                                                0.1,
                                              ),
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 64,
                                                color: AppColors.grey,
                                              ),
                                            ),
                                      );
                                    },
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: post.imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        color: AppColors.grey.withOpacity(0.1),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.white,
                                                ),
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: AppColors.grey.withOpacity(0.1),
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 64,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 4.0,
                                  sigmaY: 4.0,
                                ),
                                child: Container(color: Colors.black38),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            Align(
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Hero(
                                  tag: 'post_centered_image_${post.id}',
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
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: post.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Container(
                                                  width: 150,
                                                  height: 150,
                                                  color: AppColors.white
                                                      .withOpacity(0.2),
                                                  child: const Icon(
                                                    Icons.image,
                                                    color: AppColors.white,
                                                    size: 50,
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      width: 150,
                                                      height: 150,
                                                      color: AppColors.white
                                                          .withOpacity(0.2),
                                                      child: const Icon(
                                                        Icons.image,
                                                        color: AppColors.white,
                                                        size: 50,
                                                      ),
                                                    ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: post.imageUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          width: 150,
                                          height: 150,
                                          color: AppColors.white.withOpacity(
                                            0.2,
                                          ),
                                          child: const Icon(
                                            Icons.image,
                                            color: AppColors.white,
                                            size: 50,
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          width: 150,
                                          height: 150,
                                          color: AppColors.white.withOpacity(
                                            0.2,
                                          ),
                                          child: const Icon(
                                            Icons.image,
                                            color: AppColors.white,
                                            size: 50,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Author and Meta Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              post.author.name.isNotEmpty
                                  ? post.author.name[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                Text(
                                  _formatDate(post.createdAt),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_calculateReadTime(post.content)} min read',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Content
                      Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  post.category.icon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  post.category.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
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

                      const SizedBox(height: 32),

                      // Related Articles Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.article,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Related Articles',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'More articles in this category',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateReadTime(String content) {
    final wordCount = content.split(' ').length;
    final readTime = (wordCount / 200).ceil();
    return readTime < 1 ? 1 : readTime;
  }
}
