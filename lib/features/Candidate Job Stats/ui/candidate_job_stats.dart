import 'package:android/features/Candidate%20Job%20Stats/ui/saved_job_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../Candidate Job Stats Bloc/candidate_job_stats_bloc.dart';
import 'enrolled_jobs_screen.dart';

class CandidateJobStatsScreen extends StatefulWidget {
  const CandidateJobStatsScreen({super.key});

  @override
  State<CandidateJobStatsScreen> createState() => _CandidateJobStatsScreenState();
}

class _CandidateJobStatsScreenState extends State<CandidateJobStatsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CandidateJobStatsBloc>(context).add(FetchJobStats());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final brightness = Theme.of(context).brightness;
    final primaryColor = brightness == Brightness.light
        ? AppColors.lightPrimary
        : AppColors.darkPrimary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Job Stats"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: BlocConsumer<CandidateJobStatsBloc, CandidateJobStatsState>(
          listener: (context, state) {
            if (state is JobStatsError) {
              SnackBarUtils.showRedSnackBar(state.error, context);
            }
          },
          builder: (context, state) {
            if (state is JobStatsLoading) {
              return Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: primaryColor,
                    size: 40
                ),
              );
            }

            if (state is JobStatsLoaded) {
              final stats = state.stats;
              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<CandidateJobStatsBloc>(context).add(FetchJobStats());
                },
                color: primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.02),

                      // Overview section
                      Text(
                        "Overview",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: brightness == Brightness.light
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ).animate().fadeIn(duration: 300.ms),

                      SizedBox(height: screenSize.height * 0.02),

                      // Jobs section
                      Row(
                        children: [
                          Expanded(
                            child: _buildNavigableStatCard(
                              'Saved Jobs',
                              stats['totalSavedJobs'].toString(),
                              Icons.bookmark,
                              AppColors.lightSuccess,
                                  () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(
                                create: (context) => CandidateJobStatsBloc(),
                                child: SavedJobScreen(),
                              ),));
                                  },
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.04),
                          Expanded(
                            child: _buildNavigableStatCard(
                              'Enrolled Jobs',
                              stats['totalEnrolledJobs'].toString(),
                              Icons.work_outline,
                              AppColors.lightDeepPurple,
                                  () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(
                                      create: (context) => CandidateJobStatsBloc(),
                                      child: EnrolledJobListScreen(),
                                    ),));
                                  },
                                
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                      SizedBox(height: screenSize.height * 0.03),

                      // Applications section
                      Text(
                        "Applications",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: brightness == Brightness.light
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ).animate().fadeIn(duration: 500.ms),

                      SizedBox(height: screenSize.height * 0.02),

                      _buildStatCard(
                        'Total Applications',
                        stats['applicationStats']['totalApplications'].toString(),
                        FontAwesomeIcons.fileWaveform,
                        primaryColor,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                      SizedBox(height: screenSize.height * 0.02),

                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: brightness == Brightness.light
                              ? AppColors.lightSurface
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Application Status Breakdown",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: brightness == Brightness.light
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem("Pending", AppColors.lightWarning),
                                const SizedBox(width: 24),
                                _buildLegendItem("Shortlisted", AppColors.lightSuccess),
                                const SizedBox(width: 24),
                                _buildLegendItem("Rejected", AppColors.lightError),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Bar Chart
                            Expanded(
                              child: BarChart(
                                BarChartData(

                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _getMaxValue(stats['applicationStats']),
                                  barTouchData: BarTouchData(
                                    enabled: false,
                                    touchTooltipData: BarTouchTooltipData(

                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {

                                        String status;
                                        switch (group.x) {
                                          case 0:
                                            status = 'Pending';
                                            break;
                                          case 1:
                                            status = 'Shortlisted';
                                            break;
                                          case 2:
                                            status = 'Rejected';
                                            break;
                                          default:
                                            status = '';
                                        }
                                        return BarTooltipItem(
                                          '$status: ${rod.toY.toInt()}',
                                          TextStyle(
                                            color: brightness == Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          String text = '';
                                          switch (value.toInt()) {
                                            case 0:
                                              text = 'Pending';
                                              break;
                                            case 1:
                                              text = 'Shortlisted';
                                              break;
                                            case 2:
                                              text = 'Rejected';
                                              break;
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: brightness == Brightness.light
                                                    ? AppColors.lightSecondaryText
                                                    : AppColors.darkSecondaryText,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        },
                                        reservedSize: 30,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: _getMaxValue(stats['applicationStats']) <= 5 ? 1 : (_getMaxValue(stats['applicationStats']) / 5).ceilToDouble(),
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          // Only show whole numbers
                                          if (value.toInt() == value) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Text(
                                                value.toInt().toString(),
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                 color: brightness == Brightness.light
                                                ? AppColors.lightSecondaryText
                                                    : AppColors.darkSecondaryText,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 5,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: brightness == Brightness.light
                                            ? Colors.grey[300]!
                                            : Colors.grey[800]!,
                                        strokeWidth: 0.5,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: brightness == Brightness.light
                                            ? Colors.grey[300]!
                                            : Colors.grey[800]!,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: brightness == Brightness.light
                                            ? Colors.grey[300]!
                                            : Colors.grey[800]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats['applicationStats']['pending'].toDouble(),
                                          color: AppColors.lightWarning,
                                          width: 22,
                                          borderRadius: BorderRadius.circular(4),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: _getMaxValue(stats['applicationStats']),
                                            color: AppColors.lightWarning.withOpacity(0.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats['applicationStats']['shortlisted'].toDouble(),
                                          color: AppColors.lightSuccess,
                                          width: 22,
                                          borderRadius: BorderRadius.circular(4),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: _getMaxValue(stats['applicationStats']),
                                            color: AppColors.lightSuccess.withOpacity(0.1),
                                          ),
                                        ),
                                      ],

                                    ),
                                    BarChartGroupData(
                                      x: 2,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats['applicationStats']['rejected'].toDouble(),
                                          color: AppColors.lightError,
                                          width: 22,
                                          borderRadius: BorderRadius.circular(4),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: _getMaxValue(stats['applicationStats']),
                                            color: AppColors.lightError.withOpacity(0.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 700.ms),
                    ],
                  ),
                ),
              );
            }

            if (state is JobStatsError) {
              return CustomErrorScreen(
                message: state.error,
                onRetry: () {
                  BlocProvider.of<CandidateJobStatsBloc>(context).add(FetchJobStats());
                },
              );
            }

            return Center(
              child: Text(
                'No stats available',
                style: TextStyle(
                  color: brightness == Brightness.light
                      ? AppColors.lightSecondaryText
                      : AppColors.darkSecondaryText,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  double _getMaxValue(Map<String, dynamic> stats) {
    double maxValue = 0;
    stats.forEach((key, value) {
      if (key != 'totalApplications' && value > maxValue) {
        maxValue = value.toDouble();
      }
    });
    // Add some padding to the max value
    return maxValue * 1.2;
  }
  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightText
                : AppColors.darkText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigableStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    final brightness = Theme.of(context).brightness;
    final cardColor = brightness == Brightness.light
        ? AppColors.lightBackground
        : AppColors.darkSurface;
    final textColor = brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.darkText;
    final primaryColor = brightness == Brightness.light
        ? AppColors.lightPrimary
        : AppColors.darkPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                radius: 30,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Details",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final brightness = Theme.of(context).brightness;
    final cardColor = brightness == Brightness.light
        ? AppColors.lightSurface
        : AppColors.darkSurface;
    final textColor = brightness == Brightness.light
        ? AppColors.lightText
        : AppColors.darkText;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 24,
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: textColor,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ),
    );
  }

}