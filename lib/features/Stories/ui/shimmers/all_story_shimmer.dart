import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StoriesShimmerScreen extends StatelessWidget {
  const StoriesShimmerScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: _buildShimmerCard(screenSize),
        );
      },
    );
  }

  Widget _buildShimmerCard(Size screenSize) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Shimmer
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: 16,
              width: screenSize.width * 0.4,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 12,
              width: screenSize.width * 0.3,
              color: Colors.white,
              margin: EdgeInsets.only(top: 8),
            ),
          ),

          // Title Shimmer
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.height * 0.01,
            ),
            child: Container(
              height: 20,
              width: screenSize.width * 0.6,
              color: Colors.white,
            ),
          ),

          // Media Shimmer
          Container(
            height: screenSize.height * 0.25,
            width: double.infinity,
            color: Colors.white,
          ),

          // Content Shimmer
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 8),
                ),
                Container(
                  height: 16,
                  width: screenSize.width * 0.8,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Tags Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: Row(
              children: List.generate(3, (index) =>
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Container(
                      height: 32,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
              ),
            ),
          ),

          // Interaction Buttons Shimmer
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) =>
                  Container(
                    height: 20,
                    width: 60,
                    color: Colors.white,
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }
}