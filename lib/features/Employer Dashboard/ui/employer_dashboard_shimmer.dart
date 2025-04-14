import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EmployerDashboardShimmer extends StatelessWidget {
  const EmployerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode
    bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    // Define shimmer colors based on theme
    Color baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    Color highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    // Define container color based on theme
    Color containerColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    // Define card color based on theme
    final cardColor = isDarkMode ? Theme.of(context).cardColor : Colors.white;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerCard(
                  cardColor: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerText(
                        width: 150,
                        height: 24,
                        color: containerColor,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildShimmerCircle(containerColor),
                          _buildShimmerCircle(containerColor),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildShimmerText(
                        width: 200,
                        height: 20,
                        color: containerColor,
                      ),
                    ],
                  ),
                ),
                _buildShimmerCard(
                  cardColor: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShimmerText(
                            width: 150,
                            height: 24,
                            color: containerColor,
                          ),
                          _buildShimmerIcon(containerColor),
                        ],
                      ),
                      Divider(color: containerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShimmerInsightCard(containerColor),
                          _buildShimmerInsightCard(containerColor),
                          _buildShimmerInsightCard(containerColor),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildShimmerList(containerColor)),
                          Expanded(child: _buildShimmerList(containerColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildShimmerCard(
                  cardColor: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShimmerText(
                            width: 150,
                            height: 24,
                            color: containerColor,
                          ),
                          _buildShimmerIcon(containerColor),
                        ],
                      ),
                      Divider(color: containerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShimmerInsightCard(containerColor),
                          _buildShimmerInsightCard(containerColor),
                          _buildShimmerInsightCard(containerColor),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildShimmerText(
                        width: 150,
                        height: 20,
                        color: containerColor,
                      ),
                      SizedBox(height: 16),
                      _buildShimmerBarChart(containerColor),
                    ],
                  ),
                ),
                _buildShimmerCard(
                  cardColor: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerText(
                        width: 180,
                        height: 24,
                        color: containerColor,
                      ),
                      SizedBox(height: 16),
                      _buildShimmerListTile(containerColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard({
    required Widget child,
    required Color cardColor,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildShimmerText({
    double? width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShimmerIcon(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShimmerCircle(Color color) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        _buildShimmerText(width: 100, height: 16, color: color),
        _buildShimmerText(width: 80, height: 14, color: color),
      ],
    );
  }

  Widget _buildShimmerInsightCard(Color color) {
    return Container(
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildShimmerList(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerText(width: 120, height: 20, color: color),
        SizedBox(height: 8),
        ...List.generate(
            3,
            (_) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 8),
                      _buildShimmerText(width: 100, height: 16, color: color),
                    ],
                  ),
                )),
      ],
    );
  }

  Widget _buildShimmerBarChart(Color color) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildShimmerListTile(Color color) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerText(width: 150, height: 16, color: color),
              SizedBox(height: 8),
              _buildShimmerText(width: 100, height: 14, color: color),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildShimmerText(width: 80, height: 16, color: color),
            SizedBox(height: 8),
            _buildShimmerText(width: 60, height: 14, color: color),
          ],
        ),
      ],
    );
  }
}
