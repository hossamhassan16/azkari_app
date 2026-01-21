import 'package:flutter/material.dart';

class AzkarProgressCard extends StatelessWidget {
  final String title;
  final double progress; // 0.0 -> 1.0
  final VoidCallback onTap;

  const AzkarProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C), // dark theme
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Top Progress Bar
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 6,
                width: double.infinity,
                color: Colors.white.withOpacity(0.08),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    height: 6,
                    width: MediaQuery.of(context).size.width * clampedProgress,
                    color: const Color(0xFF2ECC71), // green
                  ),
                ),
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 16),

                  // Title
                  Expanded(
                    child: Text(
                      title,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Percentage indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${(clampedProgress * 100).round()}%',
                      style: TextStyle(
                        color: clampedProgress == 1.0
                            ? const Color(0xFF2ECC71)
                            : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
