import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../../core/utils/hiveUtils.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';
import '../bloc/employer_dashboard_bloc.dart';
import 'employer_dashboard_shimmer.dart';


class DashboardContent extends StatefulWidget {
  // final CompanyDetails? companyData;
  // final Employer? employerData;
  // final Future<void> Function() onRefresh;

  const DashboardContent({super.key, });
  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {


  @override
  void initState() {
     BlocProvider.of<EmployerDashboardBloc>(context).add(FetchDashboardData());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocConsumer<EmployerDashboardBloc, EmployerDashboardState>(
      listener: (context, state) {
        if (state is EmployerDashboardError) {
          SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
      },
      builder: (context, state) {
        // if (widget.employerData == null || widget.companyData == null) {
        //   return const CustomErrorScreen(
        //     message: "Unable to load user data",
        //     onRetry: null,
        //   );
        // }
        if (state is EmployerDashboardLoading) {
          return EmployerDashboardShimmer();
        }
        if (state is EmployerDashboardError) {
          return CustomErrorScreen(
            message: state.error.toString(),
            onRetry: () {
              context.read<EmployerDashboardBloc>().add(FetchDashboardData());
            },
          );
        }
        if(state is EmployerDashboardLoaded) {
          Map<String,dynamic> dashboardStats = state.data;
          List<Map<String,dynamic>> recentApplications = List<Map<String,dynamic>>.from(dashboardStats["recentApplications"]) ?? [];
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<EmployerDashboardBloc>(context).add(FetchDashboardData());
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCompletionSection(dashboardStats, screenSize),
                    _buildJobInsightsSection(dashboardStats, screenSize),
                    _buildApplicationInsightsSection(dashboardStats, screenSize),
                    SizedBox(height: screenSize.height*0.01),
                    _buildRecentApplicationsSection(screenSize,recentApplications),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildProfileCompletionSection(Map<String, dynamic> dashboardStats,Size screenSize) {
    // Extract profile stats from the dashboard data
    final profileStats = dashboardStats['profileStats'] ?? {};
    final employerProfileCompletion = profileStats['employerProfileCompletion'] ?? {};
    final companyProfileCompletion = profileStats['companyProfileCompletion'] ?? {};
    final missingFields = profileStats['missingFields'] ?? {};
    final employerField=missingFields['employer'] ?? [];
    final company=missingFields['company'] ?? [];
    final overAllMissingFields = [
      ...?employerField,
      ...?company
    ].where((field) => field != null && field.toString().isNotEmpty).toList();


    return Card(
      elevation: 4,
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Completion',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: screenSize.width*0.045,
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileCompletionCircle(
                    'Employer Profile',
                    (employerProfileCompletion['score'] ?? 0) / (employerProfileCompletion['totalFields'] ?? 1),
                    '${employerProfileCompletion['score'] ?? 0}/${employerProfileCompletion['totalFields'] ?? 0} Fields',screenSize
                ),
                _buildProfileCompletionCircle(
                    'Company Profile',
                    (companyProfileCompletion['score'] ?? 0) / (companyProfileCompletion['totalFields'] ?? 1),
                    '${companyProfileCompletion['score'] ?? 0}/${companyProfileCompletion['totalFields'] ?? 0} Fields',screenSize
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.02),
            Text(
              'Missing Fields: ${overAllMissingFields.isNotEmpty ? overAllMissingFields.join(', ') : "None"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: screenSize.width*0.04,
                  color: Colors.orange
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInsightsSection(Map<String, dynamic> dashboardStats, Size screenSize) {
    final jobInsights = dashboardStats['jobInsights'] ?? {};
    final overview = jobInsights['overview'] ?? {};
    final employmentType = jobInsights['employmentType'] ?? [];
    final jobsByLocation = jobInsights['jobsByLocation'] ?? [];

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Job Insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: screenSize.width*0.045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.bar_chart),
              ],
            ),
            Divider(height: 20, color: Colors.grey.shade300),

            // Insight Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _buildEnhancedInsightCard('Total Jobs', '${overview['totalJobs'] ?? 0}', Icons.work_outline, AppColors.lightPrimary,screenSize),
                _buildEnhancedInsightCard('Open Jobs', '${overview['openJobs'] ?? 0}', Icons.check_circle_outline, AppColors.lightSuccess,screenSize),
                _buildEnhancedInsightCard('Closed Jobs', '${overview['closedJobs'] ?? 0}', Icons.cancel_outlined, AppColors.lightError,screenSize),
              ],
            ),

            SizedBox(height: screenSize.height*0.02),

            // Job Type and Location Insights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: _buildJobTypeBreakdown(employmentType,screenSize),
                  ),
                  // SizedBox(width: screenSize.width*0.05,),
                  Container(
                    child: _buildJobLocationBreakdown(jobsByLocation,screenSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeBreakdown(List<dynamic> employmentType,Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employment Type',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: screenSize.width*0.04
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenSize.width*0.015),
        ...employmentType.map((type) =>
            _buildBreakdownRow(type['_id'] ?? 'Unknown', type['count'] ?? 0, Colors.blue,screenSize)
        ),
      ],
    );
  }

  Widget _buildJobLocationBreakdown(List<dynamic> jobsByLocation,Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          'Job Location',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: screenSize.width*0.04
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenSize.width*0.015),
        ...jobsByLocation.map((location) =>
            _buildBreakdownRow(location['_id'] ?? 'Unknown', location['count'] ?? 0,
                location['_id'] == 'Remote' ? Colors.green : Colors.orange,screenSize)
        ),
      ],
    );
  }

  Widget _buildApplicationInsightsSection(Map<String, dynamic> dashboardStats, Size screenSize) {
    final applicationInsights = dashboardStats['applicationInsights'] ?? {};
    final overview = applicationInsights['overview'] ?? {};

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(0),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Application Insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: screenSize.width*0.045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.analytics_outlined),
              ],
            ),
            Divider(height: 20, color: Colors.grey.shade300),

            // Insight Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEnhancedInsightCard('Total', '${overview['totalApplications'] ?? 0}', Icons.people_outline, Colors.purple,screenSize),
                _buildEnhancedInsightCard('Shortlisted', '${overview['shortlistedApplications'] ?? 0}', Icons.check_circle_outline, Colors.green,screenSize),
                _buildEnhancedInsightCard('Rejected', '${overview['rejectedApplications'] ?? 0}', Icons.cancel_outlined, Colors.red,screenSize),
              ],
            ),

            SizedBox(height: screenSize.height*0.02),
            _buildApplicationStatusBarChart(overview,screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationStatusBarChart(Map<String, dynamic> overview,Size screenSize) {
    final totalApplications = overview['totalApplications'] ?? 0;
    final shortlistedApplications = overview['shortlistedApplications'] ?? 0;
    final rejectedApplications = overview['rejectedApplications'] ?? 0;
    final pendingApplications = totalApplications - shortlistedApplications - rejectedApplications;
    double maxY=totalApplications.toDouble() > 0 ? totalApplications.toDouble() : 5;




    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Status',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: screenSize.width*0.045,
            // color: AppColors.secondary
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenSize.height*0.01),
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(

              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barGroups: [
                _buildApplicationBar('Shortlisted', shortlistedApplications.toDouble(), AppColors.lightSuccess),
                _buildApplicationBar('Rejected', rejectedApplications.toDouble(), AppColors.lightError),
                _buildApplicationBar('Pending', pendingApplications.toDouble(), AppColors.lightWarning),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY <= 5 ? 1 : (maxY / 5).ceilToDouble(),
                    getTitlesWidget: (double value, TitleMeta meta) {
                      // Only show whole numbers
                      if (value.toInt() == value) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 40, // Increased reserved size for left titles
                  ),
                ),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: false
                    )
                ),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: false
                    )
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const statuses = ['Shortlisted', 'Rejected', 'Pending'];
                      return Text(statuses[value.toInt()],style: Theme.of(context).textTheme.bodySmall,overflow:TextOverflow.ellipsis,);
                    },
                  ),
                ),
              ),

              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toInt().toString(),
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),

                    );
                  },
                ),
                enabled: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCircle(String title, double percentage, String details,Size screenSize) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 10.0,
          percent: percentage,
          progressColor:  Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
          // fillColor:  Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
          center: Text('${(percentage * 100).toInt()}%',style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary

          ),),
          // progressColor: AppColors.primary,
        ),
        SizedBox(height: screenSize.height*0.02),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: screenSize.width*0.045
          ),
        ),
        Text(details, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: screenSize.width*0.04
        ),),
      ],
    );
  }

  Widget _buildEnhancedInsightCard(String title, String count, IconData icon, Color color,Size screenSize) {
    return Card(
     // width: screenSize.width*0.28,
      margin: EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(color: color.withOpacity(0.3), width: 1)),
      color: color.withOpacity(0.1),

      child: SizedBox(
        width: screenSize.width*0.26,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(height: screenSize.height*0.01),
              Text(
                  count,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: screenSize.width*0.04
                  )
              ),
              Text(
                  title,
                  maxLines: 1,
                  overflow:TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                      color: color,
                      fontSize: screenSize.width*0.035
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, Color color,Size screenSize) {
    return Row(
      children: [
        Container(
          width: screenSize.width*0.06,
          height: screenSize.height*0.01,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text('$label: $count',style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: screenSize.width*0.04
        ),),
      ],
    );
  }

  BarChartGroupData _buildApplicationBar(String x, double value, Color color) {
    return BarChartGroupData(
      x: x == 'Shortlisted' ? 0 : (x == 'Rejected' ? 1 : 2),
      // showingTooltipIndicators: [0],
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecentApplicationsSection(Size screenSize,List<Map<String,dynamic>> recentApplications) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Applications',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: screenSize.width*0.045,
                fontWeight: FontWeight.w700,
              ),),
            SizedBox(height: screenSize.height*0.02),
            recentApplications.isEmpty? SizedBox(
              child: Center(child: Text("No Applications")),
            ):ListView.builder(
              shrinkWrap: true,
              itemCount: recentApplications.length,
              itemBuilder: (BuildContext context, int index) {
                final application =recentApplications[index];

                return _buildApplicationItem(
                    application["candidateName"],
                    application["jobTitle"],
                    application["status"],
                    application["appliedDate"],
                    screenSize
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationItem(String name, String jobTitle, String status, String date,Size screenSize) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person, color: Colors.blue),
      ),
      title: Text(name,style: Theme.of(context).textTheme.bodySmall,),
      subtitle: Text(jobTitle,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: screenSize.width*0.045,
      )),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            status,
            style: TextStyle(
              color: status == 'Shortlisted' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
              date, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: screenSize.width*0.025,
              fontWeight: FontWeight.w600
          )
          ),
        ],
      ),
    );
  }
}
