import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/story_model.dart';
import '../../services/story_service.dart';

class StoryViewerScreen extends StatefulWidget {
  final StoryModel story;

  const StoryViewerScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _autoCloseTimer;
  final _storyService = StoryService();

  // Story duration (10 seconds)
  static const Duration _storyDuration = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    
    // Mark story as viewed
    _markAsViewed();
    
    // Initialize progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    );
    
    // Start progress animation
    _progressController.forward();
    
    // Auto-close when animation completes
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _closeStory();
      }
    });
  }

  Future<void> _markAsViewed() async {
    await _storyService.markAsViewed(widget.story.id);
  }

  void _closeStory() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  // Calculate font size based on content length to prevent overflow
  double _calculateFontSize() {
    final contentLength = widget.story.content.length;
    
    if (contentLength < 100) {
      return 28.0; // Short content
    } else if (contentLength < 200) {
      return 24.0; // Medium content
    } else if (contentLength < 350) {
      return 20.0; // Long content
    } else if (contentLength < 500) {
      return 18.0; // Very long content
    } else {
      return 16.0; // Extremely long content
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          // Pause/resume on tap (optional)
          if (_progressController.isAnimating) {
            _progressController.stop();
          } else {
            _progressController.forward();
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Icon(
                        widget.story.icon,
                        color: AppColors.primaryGreen,
                        size: 60,
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        widget.story.displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Content (Arabic RTL) with dynamic font size
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          widget.story.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _calculateFontSize(), // ✅ Dynamic font size
                            height: 2.0,
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Progress bar at top
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 3,
                      ),
                    );
                  },
                ),
              ),
              
              // Close button (top right)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _closeStory,
                ),
              ),
              
              // Next arrow (bottom right) - optional
              Positioned(
                bottom: 40,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _closeStory,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
