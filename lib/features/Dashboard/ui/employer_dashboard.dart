import 'package:android/core/utils/custonErrorUtils.dart';
import 'package:android/features/Dashboard/bloc/employer_dashboard_bloc.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/utils/utils.dart';
import 'employer_dashboard_shimmer.dart';




class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});


  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  Map<String,dynamic>? companyData;

  Map<String,dynamic>? employerData;

  Future<void> loadData() async{
    companyData= await HiveUtils.getCompanyData() ;
    employerData =await HiveUtils.getEmployerData();
  }

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    loadData();
    BlocProvider.of<EmployerDashboardBloc>(context).add(FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Employer Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: BlocConsumer<EmployerDashboardBloc, EmployerDashboardState>(
              listener: (context, state) {
                if (state is EmployerDashboardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error.toString())),
                  );
                }
              },
              builder: (context, state) {
                if(state is EmployerDashboardLoading){
                  return EmployerDashboardShimmer();
                }
                if (state is EmployerDashboardError) {
                  return CustomErrorScreen(message: state.error.toString(),onRetry: (){
                    BlocProvider.of<EmployerDashboardBloc>(context).add(FetchDashboardData());
                  },);
                }
                if(state is EmployerDashboardLoaded){
                  Map<String,dynamic> dashboardStats = state.data;
                  return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCompletionSection(dashboardStats),
                          _buildJobInsightsSection(dashboardStats),
                          _buildApplicationInsightsSection(dashboardStats),
                          _buildRecentApplicationsSection(), // You might want to update this too
                        ],
                      ),
                  );
                }

                return SizedBox();

              },
              ),
        ),
      );
  }
  Widget _buildProfileCompletionSection(Map<String, dynamic> dashboardStats) {
    // Extract profile stats from the dashboard data
    final profileStats = dashboardStats['profileStats'] ?? {};
    final employerProfileCompletion = profileStats['employerProfileCompletion'] ?? {};
    final companyProfileCompletion = profileStats['companyProfileCompletion'] ?? {};
    final missingFields = profileStats['missingFields'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileCompletionCircle(
                  'Employer Profile',
                  (employerProfileCompletion['score'] ?? 0) / (employerProfileCompletion['totalFields'] ?? 1),
                  '${employerProfileCompletion['score'] ?? 0}/${employerProfileCompletion['totalFields'] ?? 0} Fields',
                ),
                _buildProfileCompletionCircle(
                  'Company Profile',
                  (companyProfileCompletion['score'] ?? 0) / (companyProfileCompletion['totalFields'] ?? 1),
                  '${companyProfileCompletion['score'] ?? 0}/${companyProfileCompletion['totalFields'] ?? 0} Fields',
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Missing Fields: ${(missingFields['employer'] as List?)?.join(', ') ?? 'None'}',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInsightsSection(Map<String, dynamic> dashboardStats) {
    final jobInsights = dashboardStats['jobInsights'] ?? {};
    final overview = jobInsights['overview'] ?? {};
    final jobsByType = jobInsights['jobsByType'] ?? [];
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                ),
                Icon(Icons.bar_chart, color: Colors.deepPurple),
              ],
            ),
            Divider(height: 20, color: Colors.grey.shade300),

            // Insight Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEnhancedInsightCard('Total Jobs', '${overview['totalJobs'] ?? 0}', Icons.work_outline, Colors.blue),
                _buildEnhancedInsightCard('Open Jobs', '${overview['openJobs'] ?? 0}', Icons.check_circle_outline, Colors.green),
                _buildEnhancedInsightCard('Closed Jobs', '${overview['closedJobs'] ?? 0}', Icons.cancel_outlined, Colors.red),
              ],
            ),

            SizedBox(height: 16),

            // Job Type and Location Insights
            Row(
              children: [
                Expanded(
                  child: _buildJobTypeBreakdown(jobsByType),
                ),
                Expanded(
                  child: _buildJobLocationBreakdown(jobsByLocation),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeBreakdown(List<dynamic> jobsByType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Type Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...jobsByType.map((type) =>
            _buildBreakdownRow(type['_id'] ?? 'Unknown', type['count'] ?? 0, Colors.blue)
        ).toList(),
      ],
    );
  }

  Widget _buildJobLocationBreakdown(List<dynamic> jobsByLocation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Job Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...jobsByLocation.map((location) =>
            _buildBreakdownRow(location['_id'] ?? 'Unknown', location['count'] ?? 0,
                location['_id'] == 'Remote' ? Colors.green : Colors.orange)
        ).toList(),
      ],
    );
  }

  Widget _buildApplicationInsightsSection(Map<String, dynamic> dashboardStats) {
    final applicationInsights = dashboardStats['applicationInsights'] ?? {};
    final overview = applicationInsights['overview'] ?? {};

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
                  'Application Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                ),
                Icon(Icons.analytics_outlined, color: Colors.deepPurple),
              ],
            ),
            Divider(height: 20, color: Colors.grey.shade300),

            // Insight Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEnhancedInsightCard('Total', '${overview['totalApplications'] ?? 0}', Icons.people_outline, Colors.purple),
                _buildEnhancedInsightCard('Shortlisted', '${overview['shortlistedApplications'] ?? 0}', Icons.check_circle_outline, Colors.green),
                _buildEnhancedInsightCard('Rejected', '${overview['rejectedApplications'] ?? 0}', Icons.cancel_outlined, Colors.red),
              ],
            ),

            SizedBox(height: 16),
            _buildApplicationStatusBarChart(overview),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationStatusBarChart(Map<String, dynamic> overview) {
    final totalApplications = overview['totalApplications'] ?? 0;
    final shortlistedApplications = overview['shortlistedApplications'] ?? 0;
    final rejectedApplications = overview['rejectedApplications'] ?? 0;
    final pendingApplications = totalApplications - shortlistedApplications - rejectedApplications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: totalApplications.toDouble() > 0 ? totalApplications.toDouble() : 5,
              barGroups: [
                _buildApplicationBar('Shortlisted', shortlistedApplications.toDouble(), Colors.green),
                _buildApplicationBar('Rejected', rejectedApplications.toDouble(), Colors.red),
                _buildApplicationBar('Pending', pendingApplications.toDouble(), Colors.orange),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const statuses = ['Shortlisted', 'Rejected', 'Pending'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(statuses[value.toInt()]),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // Widget _buildProfileCompletionSection() {
  //   return Card(
  //     elevation: 4,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Profile Completion',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               _buildProfileCompletionCircle(
  //                 'Employer Profile',
  //                 0.83,
  //                 '5/6 Fields',
  //               ),
  //               _buildProfileCompletionCircle(
  //                 'Company Profile',
  //                 1.0,
  //                 '18/18 Fields',
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 16),
  //           Text(
  //             'Missing Fields: Gender',
  //             style: TextStyle(
  //               color: Colors.orange,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProfileCompletionCircle(String title, double percentage, String details) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 10.0,
          percent: percentage,
          center: Text('${(percentage * 100).toInt()}%'),
          progressColor: Colors.green,
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(details),
      ],
    );
  }

  // Widget _buildJobInsightsSection() {
  //   return Card(
  //     elevation: 4,
  //     margin: EdgeInsets.symmetric(vertical: 12),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Job Insights',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.deepPurple,
  //                 ),
  //               ),
  //               Icon(Icons.bar_chart, color: Colors.deepPurple),
  //             ],
  //           ),
  //           Divider(height: 20, color: Colors.grey.shade300),
  //
  //           // Insight Cards Row
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               _buildEnhancedInsightCard('Total Jobs', '20', Icons.work_outline, Colors.blue),
  //               _buildEnhancedInsightCard('Open Jobs', '20', Icons.check_circle_outline, Colors.green),
  //               _buildEnhancedInsightCard('Closed Jobs', '0', Icons.cancel_outlined, Colors.red),
  //             ],
  //           ),
  //
  //           SizedBox(height: 16),
  //
  //           // Job Type and Location Insights
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: _buildJobTypeBreakdown(),
  //               ),
  //               Expanded(
  //                 child: _buildJobLocationBreakdown(),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEnhancedInsightCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildApplicationInsightsSection() {
  //   return Card(
  //     elevation: 4,
  //     margin: EdgeInsets.symmetric(vertical: 12),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Application Insights',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.deepPurple,
  //                 ),
  //               ),
  //               Icon(Icons.analytics_outlined, color: Colors.deepPurple),
  //             ],
  //           ),
  //           Divider(height: 20, color: Colors.grey.shade300),
  //
  //           // Insight Cards Row
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               _buildEnhancedInsightCard('Total', '1', Icons.people_outline, Colors.purple),
  //               _buildEnhancedInsightCard('Shortlisted', '1', Icons.check_circle_outline, Colors.green),
  //               _buildEnhancedInsightCard('Rejected', '0', Icons.cancel_outlined, Colors.red),
  //             ],
  //           ),
  //
  //           SizedBox(height: 16),
  //           _buildApplicationStatusBarChart(),
  //           SizedBox(height: 8),
  //         ],
  //       ),
  //     ),
  //   );
  // }




  // Widget _buildJobLocationBreakdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //         SizedBox(height: 8),
  //       Text(
  //         'Job Location',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //        SizedBox(height: 8),
  //       _buildBreakdownRow('Remote', 19, Colors.green),
  //       _buildBreakdownRow('On-site', 1, Colors.orange),
  //     ],
  //   );
  // }
  //
  //
  // Widget _buildJobTypeBreakdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Job Type Breakdown',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 8),
  //       _buildBreakdownRow('Full-time', 20, Colors.blue),
  //     ],
  //   );
  // }

  Widget _buildBreakdownRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text('$label: $count'),
      ],
    );
  }


  // Widget _buildApplicationStatusBarChart() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Application Status',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 16),
  //       AspectRatio(
  //         aspectRatio: 1.7,
  //         child: BarChart(
  //           BarChartData(
  //             alignment: BarChartAlignment.spaceAround,
  //             maxY: 5,
  //             barGroups: [
  //               _buildApplicationBar('Shortlisted', 1, Colors.green),
  //               _buildApplicationBar('Rejected', 0, Colors.red),
  //               _buildApplicationBar('Pending', 0, Colors.orange),
  //             ],
  //             titlesData: FlTitlesData(
  //               leftTitles: AxisTitles(
  //                 sideTitles: SideTitles(showTitles: true),
  //               ),
  //               bottomTitles: AxisTitles(
  //                 sideTitles: SideTitles(
  //                   showTitles: true,
  //                   getTitlesWidget: (double value, TitleMeta meta) {
  //                     const statuses = ['Shortlisted', 'Rejected', 'Pending'];
  //                     return Padding(
  //                       padding: const EdgeInsets.only(top: 8.0),
  //                       child: Text(statuses[value.toInt()]),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  BarChartGroupData _buildApplicationBar(String x, double value, Color color) {
    return BarChartGroupData(
      x: x == 'Shortlisted' ? 0 : (x == 'Rejected' ? 1 : 2),
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 40,
        ),
      ],
    );
  }


  Widget _buildRecentApplicationsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildApplicationItem(
              'Ankit Sharma',
              'Web Designer',
              'Shortlisted',
              '2024-12-12',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationItem(String name, String jobTitle, String status, String date) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person, color: Colors.blue),
      ),
      title: Text(name),
      subtitle: Text(jobTitle),
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
            date,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

}
