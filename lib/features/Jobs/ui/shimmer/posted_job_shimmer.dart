import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostedJobsShimmer extends StatelessWidget {
  const PostedJobsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define shimmer colors based on theme
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    final shimmerBackground = isDarkMode ? Colors.grey[900]! : Colors.white;

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: Theme.of(context).cardTheme.copyWith(
          color: shimmerBackground,
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenSize.width * 0.04,
              horizontal: screenSize.width * 0.02,
            ),
            child: Expanded(
              child: ListView.builder(
                itemCount: 3, // Show 3 shimmer cards
                itemBuilder: (context, index) {
                  return _buildJobCardShimmer(
                    screenSize,
                    baseColor,
                    highlightColor,
                    shimmerBackground,
                    isDarkMode,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildJobCardShimmer(
      Size screenSize,
      Color baseColor,
      Color highlightColor,
      Color shimmerBackground,
      bool isDarkMode,
      ) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenSize.width * 0.5,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: screenSize.width * 0.15,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Company name
              Container(
                width: screenSize.width * 0.4,
                height: 16,
                decoration: BoxDecoration(
                  color: shimmerBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 16),

              // Info pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    3,
                        (index) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        width: screenSize.width * 0.25,
                        height: 32,
                        decoration: BoxDecoration(
                          color: shimmerBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Salary and deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenSize.width * 0.3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: screenSize.width * 0.25,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Responsibilities heading
              Container(
                width: screenSize.width * 0.4,
                height: 20,
                decoration: BoxDecoration(
                  color: shimmerBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 8),

              // Responsibilities list
              ...List.generate(
                2,
                    (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: shimmerBackground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: screenSize.width * 0.7,
                        height: 16,
                        decoration: BoxDecoration(
                          color: shimmerBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Skills chips
              Row(
                children: List.generate(
                  3,
                      (index) => Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Container(
                      width: screenSize.width * 0.2,
                      height: 32,
                      decoration: BoxDecoration(
                        color: shimmerBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: shimmerBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: isDarkMode ? Border.all(color: Colors.grey[800]!) : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: shimmerBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}