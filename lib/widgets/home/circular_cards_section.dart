import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/story_model.dart';
import '../../services/story_service.dart';
import '../../screens/stories/story_viewer_screen.dart';

class CircularCardsSection extends StatefulWidget {
  const CircularCardsSection({super.key});

  @override
  State<CircularCardsSection> createState() => _CircularCardsSectionState();
}

class _CircularCardsSectionState extends State<CircularCardsSection> {
  final _storyService = StoryService();
  List<StoryModel> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() {
    setState(() {
      _stories = _storyService.getStories();
    });
  }

  Future<void> _openStory(StoryModel story) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(story: story),
      ),
    );
    // Refresh stories after viewing
    _loadStories();
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return const SizedBox(height: 100);
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CircularStoryCard(
              story: story,
              onTap: () => _openStory(story),
            ),
          );
        },
      ),
    );
  }
}

class _CircularStoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;

  const _CircularStoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Color based on viewed status
    final borderColor = story.isViewed 
        ? Colors.white.withOpacity(0.4)
        : AppColors.primaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular card with gradient border (Instagram style)
          Container(
            width: 75,
            height: 75,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.isViewed
                  ? null
                  : LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: story.isViewed ? borderColor : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
              ),
              child: Center(
                child: Icon(
                  story.icon,
                  color: story.isViewed 
                      ? Colors.white.withOpacity(0.6)
                      : AppColors.primaryGreen,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Label
          SizedBox(
            width: 75,
            child: Text(
              _getShortLabel(story.type),
              style: TextStyle(
                color: story.isViewed 
                    ? Colors.white.withOpacity(0.5)
                    : AppColors.white,
                fontSize: 12,
                fontWeight: story.isViewed 
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _getShortLabel(StoryType type) {
    switch (type) {
      case StoryType.hadith:
        return 'حديث';
      case StoryType.duaa:
        return 'دعاء';
      case StoryType.ayah:
        return 'آية';
    }
  }
}
