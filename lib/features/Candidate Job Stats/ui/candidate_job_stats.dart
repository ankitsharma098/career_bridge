import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../Candidate Job Stats Bloc/candidate_job_stats_bloc.dart';

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
                                  () => _navigateToSavedJobs(context),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.04),
                          Expanded(
                            child: _buildNavigableStatCard(
                              'Enrolled Jobs',
                              stats['totalEnrolledJobs'].toString(),
                              Icons.work_outline,
                              AppColors.lightDeepPurple,
                                  () => _navigateToEnrolledJobs(context),
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
                        Icons.send,
                        primaryColor,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                      _buildStatCard(
                        'Pending',
                        stats['applicationStats']['pending'].toString(),
                        Icons.hourglass_empty,
                        AppColors.lightWarning,
                      ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),

                      _buildStatCard(
                        'Shortlisted',
                        stats['applicationStats']['shortlisted'].toString(),
                        Icons.star_outline,
                        AppColors.lightSuccess,
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),

                      _buildStatCard(
                        'Rejected',
                        stats['applicationStats']['rejected'].toString(),
                        Icons.cancel_outlined,
                        AppColors.lightError,
                      ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.2, end: 0),
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

  void _navigateToSavedJobs(BuildContext context) {
    // Navigation for saved jobs (to be implemented)
    print("Navigate to Saved Jobs");
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SavedJobsScreen()));
  }

  void _navigateToEnrolledJobs(BuildContext context) {
    // Navigation for enrolled jobs (to be implemented)
    print("Navigate to Enrolled Jobs");
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EnrolledJobsScreen()));
  }
}