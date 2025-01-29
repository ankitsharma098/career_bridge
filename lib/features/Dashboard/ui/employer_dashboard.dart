import 'dart:math';

import 'package:android/core/constants/colors.dart';
import 'package:android/core/theme/app_theme.dart';
import 'package:android/core/utils/custonErrorUtils.dart';
import 'package:android/data/models/company/company_model.dart';
import 'package:android/data/models/employer/employer_model.dart';
import 'package:android/features/Dashboard/bloc/employer_dashboard_bloc.dart';
import 'package:android/features/Jobs/bloc/jobs_bloc.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:android/features/profile/bloc/profile_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/utils/hiveUtils.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../Jobs/ui/jobs.dart';
import '../../profile/ui/employer_profile.dart';
import 'employer_dashboard_shimmer.dart';




class EmployerDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const EmployerDashboardScreen({super.key, required this.isDarkMode, required this.onThemeToggle});


  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  CompanyDetails? companyData;  // Nullable with '?'
  Employer? employerData;

  Future<void> loadData() async {
    try {
      print('Starting loadData method');

      Map<String,dynamic> employerMap = await HiveUtils.getEmployerData();
      Map<String,dynamic> companyMap = await HiveUtils.getCompanyData();


      if(employerMap.isNotEmpty){
        employerData =Employer.fromJson(employerMap);
      }else {
        employerData =Employer.fromJson({});
      }
      if(companyMap.isNotEmpty){
        companyData =CompanyDetails.fromJson(companyMap);
      }else {
        companyData = CompanyDetails.fromJson({});
      }

    } catch (e) {
      print('Error in loadData: $e');
    }
  }

   Future<void>  logout() async {

    return await HiveUtils.clearUserData();
   }
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    loadData();
    BlocProvider.of<EmployerDashboardBloc>(context).add(FetchDashboardData());
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: ()  {


                 logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => LoginBloc(),
                      child: LoginScreen(isDarkMode: widget.isDarkMode, onThemeToggle:widget.onThemeToggle),
                    ), // Navigate to login screen
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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

              return  Scaffold(
                appBar: AppBar(
                  title: Text('Employer  Dashboard'),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    loadData();
                    BlocProvider.of<EmployerDashboardBloc>(context).add(FetchDashboardData());
                  },
                  child: SingleChildScrollView(

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCompletionSection(dashboardStats,screenSize),
                          _buildJobInsightsSection(dashboardStats,screenSize),
                          _buildApplicationInsightsSection(dashboardStats,screenSize),
                          SizedBox(height: screenSize.height*0.01,),
                          _buildRecentApplicationsSection(screenSize), // You might want to update this too
                        ],
                      ),
                    ),
                  ),
                ),
                drawer: Container(
                  color: Theme.of(context).brightness == Brightness.dark ?Colors.grey[850] : Colors.white,
                  width: screenSize.width * 0.6,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        height: screenSize.height*0.25,
                        child: DrawerHeader(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: screenSize.width*0.15,
                                backgroundImage: employerData?.personalInfo.profilePic != null
                                    ? NetworkImage(employerData!.personalInfo.profilePic.toString())
                                    : null,
                                backgroundColor: AppColors.background,
                                child: employerData?.personalInfo.profilePic == null
                                    ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primary,
                                )
                                    : null,
                              ),
                              Text(
                                  employerData!.personalInfo.fullName ,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: screenSize.width*0.045,
                                      fontWeight: FontWeight.w600
                                  )
                              ),
                              Text(
                                  employerData!.personalInfo.email,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: screenSize.width*0.03,
                                      fontWeight: FontWeight.w300
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        onTap: () {
                          // Current screen, so just close the drawer
                          //Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.work,
                        title: 'Jobs',
                        onTap: () {
                          //  Navigator.pop(context);
                          Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => JobStatsScreen(), // You'll need to create this screen
                             ),
                           );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => ProfileBloc(),
                                child: EmployerProfileScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.web_stories,
                        title: 'My Blog',
                        onTap: () {
                          // Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => BlogMessagesScreen(), // You'll need to create this screen
                          //   ),
                          // );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.message,
                        title: 'Messages',
                        onTap: () {
                          // Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => BlogMessagesScreen(), // You'll need to create this screen
                          //   ),
                          // );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.event,
                        title: 'Events',
                        onTap: () {
                          // Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => EventsScreen(), // You'll need to create this screen
                          //   ),
                          // );
                        },
                      ),
                      _buildDrawerItem(
                        icon: CupertinoIcons.person_2_fill,
                        title: 'About Us',
                        onTap: () {
                          // Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => EventsScreen(), // You'll need to create this screen
                          //   ),
                          // );
                        },
                      ),
                      Divider(),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () {
                          // Implement logout logic
                          _showLogoutConfirmationDialog(context);
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              );

          }

          return SizedBox();
        },
      );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppColors.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //color: color ?? Colors.black87,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
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
    final overAllMissingFields=employerField+company;

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
              'Missing Fields: ${(overAllMissingFields as List?)?.join(', ') ?? 'None'}',
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
                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: screenSize.width*0.045,
                     fontWeight: FontWeight.w700,
                ),
                ),
                Icon(Icons.bar_chart, color: AppColors.deepPurple),
              ],
            ),
            Divider(height: 20, color: Colors.grey.shade300),

            // Insight Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEnhancedInsightCard('Total Jobs', '${overview['totalJobs'] ?? 0}', Icons.work_outline, AppColors.primary,screenSize),
                _buildEnhancedInsightCard('Open Jobs', '${overview['openJobs'] ?? 0}', Icons.check_circle_outline, AppColors.greenCircular,screenSize),
                _buildEnhancedInsightCard('Closed Jobs', '${overview['closedJobs'] ?? 0}', Icons.cancel_outlined, AppColors.error,screenSize),
              ],
            ),

            SizedBox(height: screenSize.height*0.02),

            // Job Type and Location Insights
            Row(
             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: _buildJobTypeBreakdown(jobsByType,screenSize),
                ),
                SizedBox(width: screenSize.width*0.05,),
                Container(
                  child: _buildJobLocationBreakdown(jobsByLocation,screenSize),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeBreakdown(List<dynamic> jobsByType,Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Type Breakdown',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: screenSize.width*0.04
            ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenSize.width*0.015),
        ...jobsByType.map((type) =>
            _buildBreakdownRow(type['_id'] ?? 'Unknown', type['count'] ?? 0, Colors.blue,screenSize)
        ).toList(),
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
        ).toList(),
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
            color: AppColors.secondary
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
                _buildApplicationBar('Shortlisted', shortlistedApplications.toDouble(), AppColors.greenCircular),
                _buildApplicationBar('Rejected', rejectedApplications.toDouble(), AppColors.error),
                _buildApplicationBar('Pending', pendingApplications.toDouble(), AppColors.orange),
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
          center: Text('${(percentage * 100).toInt()}%',style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.deepPurple
          ),),
          progressColor: AppColors.primary,
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
    return Container(
      width: screenSize.width*0.28,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
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


  Widget _buildRecentApplicationsSection(Size screenSize) {
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
            _buildApplicationItem(
              'Ankit Sharma',
              'Web Designer',
              'Shortlisted',
              '2024-12-12',
              screenSize
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
