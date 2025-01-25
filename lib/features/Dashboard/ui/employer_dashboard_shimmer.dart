import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EmployerDashboardShimmer extends StatelessWidget {
  const EmployerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Completion Shimmer
                _buildShimmerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerText(width: 150, height: 24),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildShimmerCircle(),
                          _buildShimmerCircle(),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildShimmerText(width: 200, height: 20),
                    ],
                  ),
                ),
      
                // Job Insights Shimmer
                _buildShimmerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShimmerText(width: 150, height: 24),
                          _buildShimmerIcon(),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShimmerInsightCard(),
                          _buildShimmerInsightCard(),
                          _buildShimmerInsightCard(),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildShimmerList()),
                          Expanded(child: _buildShimmerList()),
                        ],
                      ),
                    ],
                  ),
                ),
      
                // Application Insights Shimmer
                _buildShimmerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShimmerText(width: 180, height: 24),
                          _buildShimmerIcon(),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShimmerInsightCard(),
                          _buildShimmerInsightCard(),
                          _buildShimmerInsightCard(),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildShimmerText(width: 150, height: 20),
                      SizedBox(height: 16),
                      _buildShimmerBarChart(),
                    ],
                  ),
                ),
      
                // Recent Applications Shimmer
                _buildShimmerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerText(width: 180, height: 24),
                      SizedBox(height: 16),
                      _buildShimmerListTile(),
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

  Widget _buildShimmerCard({required Widget child}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildShimmerText({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
    );
  }

  Widget _buildShimmerIcon() {
    return Container(
      width: 24,
      height: 24,
      color: Colors.white,
    );
  }

  Widget _buildShimmerCircle() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        _buildShimmerText(width: 100, height: 16),
        _buildShimmerText(width: 80, height: 14),
      ],
    );
  }

  Widget _buildShimmerInsightCard() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerText(width: 120, height: 20),
        SizedBox(height: 8),
        ...List.generate(3, (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              _buildShimmerText(width: 100, height: 16),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildShimmerBarChart() {
    return Container(
      height: 200,
      color: Colors.white,
    );
  }

  Widget _buildShimmerListTile() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerText(width: 150, height: 16),
              SizedBox(height: 8),
              _buildShimmerText(width: 100, height: 14),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildShimmerText(width: 80, height: 16),
            SizedBox(height: 8),
            _buildShimmerText(width: 60, height: 14),
          ],
        ),
      ],
    );
  }
}