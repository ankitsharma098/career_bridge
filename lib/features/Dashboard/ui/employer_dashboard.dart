import 'package:android/core/constants/colors.dart';
import 'package:android/core/utils/customErrorUtils.dart';
import 'package:android/data/models/company/company_model.dart';
import 'package:android/data/models/employer/employer_model.dart';
import 'package:android/features/Chat/bloc/chat_bloc.dart';
import 'package:android/features/Chat/data%20service/chat_service.dart';
import 'package:android/features/Dashboard/bloc/employer_dashboard_bloc.dart';
import 'package:android/features/Stories/bloc/story_bloc.dart';
import 'package:android/features/Stories/stats_bloc/story_stats_bloc.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:android/features/profile/bloc/profile_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/utils/hiveUtils.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../About Us/ui/about_us.dart';
import '../../Chat/ui/chat.dart';
import '../../Jobs/ui/jobs.dart';
import '../../Stories/ui/all_story.dart';
import '../../Stories/ui/story_stats.dart';
import '../../profile/ui/employer_profile.dart';
import 'dashboard_stats.dart';
import 'employer_dashboard_shimmer.dart';




class EmployerDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const EmployerDashboardScreen({super.key, required this.isDarkMode, required this.onThemeToggle});


  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  CompanyDetails? companyData;
  Employer? employerData;
  bool isLoading = true;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

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
    _initializeData();
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

  Future<void> _initializeData() async {
    try {
      Map<String,dynamic> employerMap = await HiveUtils.getEmployerData();
      Map<String,dynamic> companyMap = await HiveUtils.getCompanyData();

      setState(() {
        employerData = employerMap.isNotEmpty
            ? Employer.fromJson(employerMap)
            : Employer.fromJson({});

        companyData = companyMap.isNotEmpty
            ? CompanyDetails.fromJson(companyMap)
            : CompanyDetails.fromJson({});

        isLoading = false;
      });
    } catch (e) {
      print('Error in loadData: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery.of(context).size;
    if (isLoading) {
      return  Scaffold(
        body:Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20)),
      );
    }
    return  Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? 'Dashboard'
            : _selectedIndex == 1
            ? 'Stories'
            : 'Settings'
        ),
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          BlocProvider(
            create: (context) => EmployerDashboardBloc(),
            child: DashboardContent(),
          ),
          BlocProvider(
            create: (context) => StoryBloc(),
            child: StoriesScreen(employerId: employerData!.id,),
          )
        ],
      ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),


      drawer: Container(
        color: Theme.of(context).brightness == Brightness.dark ?Colors.grey[850] : Colors.white,
        width: screenSize.width * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
               height: screenSize.height*0.26,
              child: DrawerHeader(
                // decoration: BoxDecoration(
                //   color: AppColors.primary,
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenSize.width*0.15,
                      backgroundImage: employerData?.personalInfo.profilePic != null
                          ? NetworkImage(employerData!.personalInfo.profilePic.toString())
                          : null,
                      // backgroundColor: AppColors.background,
                      child: employerData?.personalInfo.profilePic == null
                          ? Icon(
                        Icons.person,
                        size: 50,
                        // color: AppColors.primary,
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
              title: 'My Stories',
              onTap: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => StoryStatsBloc(),
                      child: StoryStatsTab(employerId: employerData!.id,),
                    ), // You'll need to create this screen
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.message,
              title: 'Messages',
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                    create: (context) => ChatBloc(),
                    child: ConversationsScreen(userId: employerData!.id,),
                  ), // You'll need to create this screen
                  ),
                );
              },
            ),
            // _buildDrawerItem(
            //   icon: Icons.event,
            //   title: 'Events',
            //   onTap: () {
            //     // Navigator.pop(context);
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => EventsScreen(), // You'll need to create this screen
            //     //   ),
            //     // );
            //   },
            // ),
            _buildDrawerItem(
              icon: CupertinoIcons.person_2_fill,
              title: 'About Us',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsScreen(), // You'll need to create this screen
                  ),
                );
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













  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        //color: color ?? AppColors.primary,
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

}
