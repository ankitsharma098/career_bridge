import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../bloc/candidate_dashboard_bloc.dart';
import 'candidate_dashboard_shimmer.dart';

class CandidateDashboardContent extends StatefulWidget {
  const CandidateDashboardContent({super.key});

  @override
  State<CandidateDashboardContent> createState() => _CandidateDashboardContentState();
}

class _CandidateDashboardContentState extends State<CandidateDashboardContent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    BlocProvider.of<CandidateDashboardBloc>(context).add(FetchDashboardData());
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];

    return BlocConsumer<CandidateDashboardBloc, CandidateDashboardState>(
      listener: (context, state) {
        if (state is CandidateDashboardError) {
          SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
      },
      builder: (context, state) {
        if (state is CandidateDashboardLoading) {
          return CandidateDashboardShimmer();
        }
        if (state is CandidateDashboardError) {
          return CustomErrorScreen(
            message: state.error.toString(),
            onRetry: () {
              context.read<CandidateDashboardBloc>().add(FetchDashboardData());
            },
          );
        }
        if (state is CandidateDashboardLoaded) {
          Map<String, dynamic> dashboardStats = state.data;
          return Container(
            color: backgroundColor,
            child: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<CandidateDashboardBloc>(context).add(FetchDashboardData());
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(screenSize),
                      _buildPersonalProfileSection(dashboardStats, screenSize),
                      _buildCareerStatsSection(dashboardStats, screenSize),
                      _buildJobStatsSection(dashboardStats, screenSize),
                      _buildJobPreferencesSection(dashboardStats, screenSize),
                      SizedBox(height: screenSize.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHeader(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Track your application progress and career growth',
            style:Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalProfileSection(Map<String, dynamic> dashboardStats, Size screenSize) {
    final personalProfile = dashboardStats['personalProfile'] ?? {};
    final profileComplete = personalProfile['profileComplete'] ?? {};
    final missingFields = profileComplete['missingFields'] ?? [];
    final percentComplete = (profileComplete['percentageComplete'] ?? 0) / 100;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.3, curve: Curves.easeOut)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.3, curve: Curves.easeOut)),
        ),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Profile Completion',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                       fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileInfoItem(
                          'Disability Type',
                          personalProfile['disabilityType'] ?? 'Not specified',
                          Icons.accessible,
                          screenSize,
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildProfileInfoItem(
                          'Matching Jobs',
                          '${personalProfile['accommodationMatches'] ?? 0}',
                          Icons.work_outline,
                          screenSize,
                        ),
                        if (missingFields.isNotEmpty) ...[
                          SizedBox(height: screenSize.height * 0.02),
                          _buildMissingFields(missingFields, screenSize),
                        ],
                      ],
                    ),
                    AnimatedProgressIndicator(
                      percentComplete: percentComplete,
                      size: screenSize.width * 0.14,
                      lineWidth: 12.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(String label, String value, IconData icon, Size screenSize) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: screenSize.width * 0.03,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style:  Theme.of(context).textTheme.bodyMedium?.copyWith(
                //fontSize: screenSize.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMissingFields(List<dynamic> missingFields, Size screenSize) {
    return Container(
      width: screenSize.width*0.5,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Missing: ${missingFields.join(', ')}',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: screenSize.width * 0.035,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerStatsSection(Map<String, dynamic> dashboardStats, Size screenSize) {
    final careerStats = dashboardStats['careerStats'] ?? {};

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Interval(0.2, 0.5, curve: Curves.easeOut)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Interval(0.2, 0.5, curve: Curves.easeOut)),
        ),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Career Insights',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInsightTile(
                      value: '${careerStats['skillMatchRate'] ?? 0}%',
                      label: 'Skill Match',
                      icon: FontAwesomeIcons.handshake,
                      color: Colors.blue,
                      screenSize: screenSize,
                    ),
                    _buildInsightTile(
                      value: '${(careerStats['totalExperienceYears'] ?? 0).toStringAsFixed(1)}',
                      label: 'Years Experience',
                      icon: Icons.work_history,
                      color: Colors.purple,
                      screenSize: screenSize,
                    ),
                    _buildInsightTile(
                      value: '${careerStats['totalCertifications'] ?? 0}',
                      label: 'Certifications',
                      icon: Icons.verified,
                      color: Colors.green,
                      screenSize: screenSize,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobStatsSection(Map<String, dynamic> dashboardStats, Size screenSize) {
    final jobStats = dashboardStats['jobStats'] ?? {};
    final applicationInsights = jobStats['applicationInsights'] ?? {};
    final successTrend = List<Map<String, dynamic>>.from(jobStats['successTrend'] ?? []);
    final topPerformingJobTypes = List<Map<String, dynamic>>.from(jobStats['topPerformingJobTypes'] ?? []);

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Interval(0.4, 0.7, curve: Curves.easeOut)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Interval(0.4, 0.7, curve: Curves.easeOut)),
        ),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Application Analytics',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildApplicationStat(
                      'Total',
                      '${applicationInsights['totalApplications'] ?? 0}',
                      Colors.blue,
                      screenSize,
                    ),
                    _buildApplicationStat(
                      'Shortlisted',
                      '${applicationInsights['shortlistedApplications'] ?? 0}',
                      Colors.green,
                      screenSize,
                    ),
                    _buildApplicationStat(
                      'Pending',
                      '${applicationInsights['pendingApplications'] ?? 0}',
                      Colors.orange,
                      screenSize,
                    ),
                    _buildApplicationStat(
                      'Rejected',
                      '${applicationInsights['rejectedApplications'] ?? 0}',
                      Colors.red,
                      screenSize,
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.025),
                _buildSuccessRateIndicator(jobStats['successRate'] ?? 0, screenSize),
                SizedBox(height: screenSize.height * 0.025),
                _buildSuccessTrendChart(successTrend, screenSize),
                SizedBox(height: screenSize.height * 0.025),
                _buildTopJobTypes(topPerformingJobTypes, screenSize),
                SizedBox(height: screenSize.height * 0.015),
                _buildJobsActivityInfo(jobStats, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobPreferencesSection(Map<String, dynamic> dashboardStats, Size screenSize) {
    final jobPreferences = dashboardStats['jobPreferences'] ?? {};
    final preferredIndustries = List<String>.from(jobPreferences['preferredIndustries'] ?? []);

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Interval(0.6, 0.9, curve: Curves.easeOut)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Interval(0.6, 0.9, curve: Curves.easeOut)),
        ),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Preferences',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildIndustriesSection(preferredIndustries, screenSize),
                SizedBox(height: screenSize.height * 0.02),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tune),
                  label: const Text('Update Preferences'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightTile({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Size screenSize,
  }) {
    return Container(
      width: screenSize.width * 0.26,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal:
      12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            value,
            style:  Theme.of(context).textTheme.bodyLarge?.copyWith(
             // fontSize: screenSize.width * 0.05,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
             // fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStat(String label, String value, Color color, Size screenSize) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: screenSize.width * 0.05,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessRateIndicator(int successRate, Size screenSize) {
    Color indicatorColor;
    if (successRate < 30) {
      indicatorColor = Colors.red;
    } else if (successRate < 70) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Success Rate',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
           // fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: successRate / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  color: indicatorColor,
                  minHeight: 10,
                ),
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Text(
              '$successRate%',
              style:Theme.of(context).textTheme.bodyLarge?.copyWith(
                //fontSize: screenSize.width * 0.04,
                fontWeight: FontWeight.bold,
                color: indicatorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessTrendChart(List<Map<String, dynamic>> successTrend, Size screenSize) {
    if (successTrend.isEmpty) {
      return _buildEmptyStateCard('No application trend data available', Icons.trending_up, screenSize);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Success Trend',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        Container(
          height: screenSize.height * 0.22,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.2,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${(value * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: screenSize.width * 0.03,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    reservedSize: 36,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < successTrend.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${successTrend[index]['month']}/${successTrend[index]['year']}',
                            style: GoogleFonts.poppins(
                              fontSize: screenSize.width * 0.03,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 28,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 1,
              lineBarsData: [
                LineChartBarData(
                  spots: successTrend
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value['successRate'].toDouble()))
                      .toList(),
                  isCurved: true,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  barWidth: 4,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkPrimary.withOpacity(0.2)
                        : AppColors.lightPrimary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopJobTypes(List<Map<String, dynamic>> topJobTypes, Size screenSize) {
    if (topJobTypes.isEmpty) {
      return _buildEmptyStateCard('No top performing job types available', Icons.work, screenSize);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing Job Types',
          style:Theme.of(context).textTheme.bodyLarge?.copyWith(
            //fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        ...topJobTypes.map(
              (type) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Text(
                  type['_id']?.toString() ?? 'Unknown Job Type',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: screenSize.width * 0.04,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Text(
                  '${type['shortlisted']} of ${type['total']}',
                  style: GoogleFonts.poppins(
                    fontSize: screenSize.width * 0.04,

                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobsActivityInfo(Map<String, dynamic> jobStats, Size screenSize) {
    final enrolledJobs = jobStats['enrolledJobsCount'] ?? 0;
    final savedJobs = jobStats['savedJobsCount'] ?? 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bookmark,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Jobs',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //fontSize: screenSize.width * 0.03,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$savedJobs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                     // fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.school,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enrolled',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //fontSize: screenSize.width * 0.03,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$enrolledJobs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      // fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndustriesSection(List<String> industries, Size screenSize) {
    if (industries.isEmpty) {
      return _buildEmptyStateCard('No preferred industries set', Icons.category, screenSize);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Industries',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          //  fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: industries.map((industry) => _buildIndustryChip(industry)).toList(),
        ),
      ],
    );
  }

  Widget _buildIndustryChip(String industry) {
    final Color chipColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Chip(
      label: Text(
        industry,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmptyStateCard(String message, IconData icon, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.3)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.grey,
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //fontSize: screenSize.width * 0.035,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedProgressIndicator extends StatelessWidget {
  final double percentComplete;
  final double size;
  final double lineWidth;

  const AnimatedProgressIndicator({
    Key? key,
    required this.percentComplete,
    required this.size,
    required this.lineWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color progressColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final Color completeColor = percentComplete == 1.0 ? Colors.green : progressColor;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: percentComplete),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return CircularPercentIndicator(
          radius: size,
          lineWidth: lineWidth,
          animation: false,
          percent: value,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: completeColor,
          backgroundColor: completeColor.withOpacity(0.2),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(value * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.bold,
                  color: completeColor,
                ),
              ),
              if (percentComplete == 1.0)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: size * 0.35,
                ),
            ],
          ),
        );
      },
    );
  }
}