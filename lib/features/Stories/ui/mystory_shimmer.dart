import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StoryStatsShimmer extends StatelessWidget {
  const StoryStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define shimmer colors based on theme
    Color baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    Color highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    // Define container color based on theme
    Color containerColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    // Define card color based on theme
    final cardColor = isDarkMode ? Theme.of(context).cardColor : Colors.white;

    final Size screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderShimmer(screenSize, containerColor, cardColor),
            SizedBox(height: screenSize.height * 0.02),
            _buildOverviewCardsShimmer(screenSize, containerColor, cardColor),
            SizedBox(height: screenSize.height * 0.03),
            _buildTopStoriesShimmer(screenSize, containerColor, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(Size screenSize, Color containerColor, Color cardColor) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: screenSize.width * 0.4,
              height: 24,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCardsShimmer(Size screenSize, Color containerColor, Color cardColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: screenSize.width * 0.03,
      crossAxisSpacing: screenSize.width * 0.03,
      childAspectRatio: 1.5,
      children: List.generate(
        4,
            (index) => Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: containerColor.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Container(
                width: screenSize.width * 0.15,
                height: 20,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Container(
                width: screenSize.width * 0.2,
                height: 16,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStoriesShimmer(Size screenSize, Color containerColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenSize.width * 0.3,
          height: 24,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        ...List.generate(
          3,
              (index) => Padding(
            padding: EdgeInsets.only(bottom: screenSize.height * 0.02),
            child: _buildStoryCardShimmer(screenSize, containerColor, cardColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCardShimmer(Size screenSize, Color containerColor, Color cardColor) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: screenSize.width * 0.4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: screenSize.width * 0.7,
              height: 16,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildMetricShimmer(screenSize, containerColor),
                SizedBox(width: 16),
                _buildMetricShimmer(screenSize, containerColor),
                SizedBox(width: 16),
                _buildMetricShimmer(screenSize, containerColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricShimmer(Size screenSize, Color containerColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        SizedBox(width: 4),
        Container(
          width: screenSize.width * 0.15,
          height: 14,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}