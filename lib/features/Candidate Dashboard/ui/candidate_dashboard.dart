import 'package:android/core/constants/colors.dart';
import 'package:android/data/models/candidate/candidate_model.dart';
import 'package:android/features/Candidate%20Job/Job%20Bloc/candidate_job_bloc.dart';
import 'package:android/features/Chat/converstation%20bloc/conversations_bloc.dart';
import 'package:android/features/Chat/data%20service/chat_service.dart';
import 'package:android/features/Stories/bloc/story_bloc.dart';
import 'package:android/features/Stories/stats_bloc/story_stats_bloc.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/ui/splash_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/utils/hiveUtils.dart';
import '../../About Us/ui/about_us.dart';
import '../../Candidate Job/ui/jobs_fetch.dart';
import '../../Candidate Profile/bloc/candidate_profile_bloc.dart';
import '../../Candidate Profile/ui/candidate_profile.dart';
import '../../Chat/ui/chat.dart';
import '../../Employer Profile/bloc/profile_bloc.dart';
import '../../Employer Profile/ui/employer_profile.dart';
import '../../Jobs/ui/jobs.dart';
import '../../Stories/ui/all_story.dart';
import '../../Stories/ui/story_stats.dart';
import '../bloc/candidate_dashboard_bloc.dart';
import 'candidate_dashboard_stats.dart';





class CandidateDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const CandidateDashboardScreen({super.key, required this.isDarkMode, required this.onThemeToggle});


  @override
  State<CandidateDashboardScreen> createState() => _CandidateDashboardScreenState();
}

class _CandidateDashboardScreenState extends State<CandidateDashboardScreen> {

  Candidate? candidateData;
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
                      child: AuthenticationScreen(isDarkMode: _isDarkMode, toggleTheme: toggleTheme),
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
      Map<String,dynamic> candidateMap = await HiveUtils.getCandidateData();

      setState(() {
        candidateData = candidateMap.isNotEmpty
            ? Candidate.fromJson(candidateMap)
            : Candidate.fromJson({});
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
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
            : 'Jobs'
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
            create: (context) => CandidateDashboardBloc(),
            child: CandidateDashboardContent(),
          ),
          BlocProvider(
            create: (context) => StoryBloc(),
            child: StoriesScreen(currentUserId: candidateData!.id, currentUserType: 'candidate',),
          ),
          BlocProvider(
            create: (context) => CandidateJobBloc(),
            child: CandidateTabJobs(),
          ),
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
            icon: Icon(FontAwesomeIcons.joget),
            label: 'Job',
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
              height: screenSize.height*0.28,
              child: DrawerHeader(
                // decoration: BoxDecoration(
                //   color: AppColors.primary,
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenSize.width * 0.15, // Consistent radius for both cases
                      backgroundColor: candidateData?.personalInfo.profilePic != null
                          ? Colors.transparent
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      child: candidateData?.personalInfo.profilePic != null
                          ? ClipOval( // Using ClipOval instead of ClipRRect for perfect circle
                        child: CachedNetworkImage(
                          imageUrl: candidateData!.personalInfo.profilePic.toString(),
                          width: screenSize.width * 0.3,  // Double the radius
                          height: screenSize.width * 0.3, // Double the radius
                          fit: BoxFit.cover, // Changed to cover for better circle filling
                          placeholder: (context, url) => Container(
                            width: screenSize.width * 0.3,
                            height: screenSize.width * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                            ),
                            child: Icon(
                              Icons.person,
                              color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: screenSize.width * 0.3,
                            height: screenSize.width * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                            ),
                            child: Center(
                              child: Text(
                                candidateData!.personalInfo.fullName[0],
                                style: TextStyle(
                                  fontSize: 24,
                                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          : Text(
                        candidateData!.personalInfo.fullName[0],
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // CircleAvatar(
                    //   radius: screenSize.width*0.15,
                    //   backgroundImage: candidateData?.personalInfo.profilePic != null
                    //       ? NetworkImage(candidateData!.personalInfo.profilePic.toString())
                    //       : null,
                    //   // backgroundColor: AppColors.background,
                    //   child: candidateData?.personalInfo.profilePic == null
                    //       ? Icon(
                    //     Icons.person,
                    //     size: 50,
                    //     // color: AppColors.primary,
                    //   )
                    //       : null,
                    // ),
                    Text(
                        candidateData!.personalInfo.fullName ,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: screenSize.width*0.045,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    Text(
                        candidateData!.personalInfo.email,
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
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.work,
              title: 'Jobs',
              onTap: () {
                //  Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => JobStatsScreen(), // You'll need to create this screen
                //   ),
                // );
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
                      create: (context) => CandidateProfileBloc(),
                      child: CandidateProfile(),
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
                      child: StoryStatsTab(employerId: candidateData!.id,),
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
                      create: (context) => ConversationsBloc(ChatRepository(), candidateData?.id , "candidate"),
                      child: ConversationsScreen(userId: candidateData!.id, userType: 'candidate',),
                    ), // You'll need to create this screen
                  ),
                );
              },
            ),
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
