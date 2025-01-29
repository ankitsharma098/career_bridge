import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ThemeAwareShimmer extends StatelessWidget {
  final Widget child;

  const ThemeAwareShimmer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class JobStatsShimmer extends StatelessWidget {
  final Size screenSize;

  const JobStatsShimmer({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define container color based on theme
    final containerColor = isDarkMode ? Colors.grey[850] : Colors.white;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: ThemeAwareShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderShimmer(containerColor),
            SizedBox(height: screenSize.height * 0.02),
            _buildOverviewCardsShimmer(containerColor),
            SizedBox(height: screenSize.height * 0.03),
            _buildDistributionSectionShimmer(containerColor),
            SizedBox(height: screenSize.height * 0.03),
            _buildConversionMetricsShimmer(containerColor),
            SizedBox(height: screenSize.height * 0.03),
            _buildInclusivityMetricsShimmer(containerColor),
            SizedBox(height: screenSize.height * 0.03),
            _buildPerformanceSectionShimmer(containerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(Color? containerColor) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: screenSize.width * 0.3,
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
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCardsShimmer(Color? containerColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: screenSize.width * 0.03,
      crossAxisSpacing: screenSize.width * 0.03,
      childAspectRatio: 1.5,
      children: List.generate(
        4,
            (index) => _buildStatsCardShimmer(containerColor),
      ),
    );
  }

  Widget _buildStatsCardShimmer(Color? containerColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: containerColor!.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: containerColor,
              shape: BoxShape.circle,
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
          SizedBox(height: 8),
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
    );
  }

  Widget _buildDistributionSectionShimmer(Color? containerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenSize.width * 0.4,
          height: 24,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildPieChartShimmer(containerColor),
            ),
            SizedBox(width: screenSize.width * 0.04),
            Expanded(
              child: _buildPieChartShimmer(containerColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChartShimmer(Color? containerColor) {
    return Card(
      elevation: 0,
      child: Container(
        height: screenSize.height * 0.3,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildConversionMetricsShimmer(Color? containerColor) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenSize.width * 0.4,
              height: 24,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Container(
              height: screenSize.height * 0.25,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusivityMetricsShimmer(Color? containerColor) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenSize.width * 0.4,
              height: 24,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildMetricTileShimmer(containerColor),
                      SizedBox(height: screenSize.height * 0.02),
                      _buildMetricTileShimmer(containerColor),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: screenSize.width * 0.2,
                    height: screenSize.width * 0.2,
                    decoration: BoxDecoration(
                      color: containerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTileShimmer(Color? containerColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenSize.width * 0.3,
                height: 16,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: screenSize.width * 0.2,
                height: 20,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSectionShimmer(Color? containerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenSize.width * 0.4,
          height: 24,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildPerformanceCardShimmer(containerColor),
        ),
      ],
    );
  }

  Widget _buildPerformanceCardShimmer(Color? containerColor) {
    return Card(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: containerColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenSize.width * 0.6,
                    height: 20,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: screenSize.width * 0.4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}