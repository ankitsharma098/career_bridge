import 'package:android/core/utils/customErrorUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/candidate/candidate_model.dart';
import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';
import '../../Chat/bloc/chat_bloc.dart';
import '../../Chat/data service/chat_service.dart';
import '../../Chat/ui/chat.dart';
import '../../Chat/ui/chat_screen.dart';
import '../bloc/see_profile_bloc.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userType;
  final String currentUserId;
  final String currentUserType;

  const UserProfileScreen({super.key, required this.userId, required this.userType, required this.currentUserId, required this.currentUserType});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    BlocProvider.of<SeeProfileBloc>(context).add(FetchUserProfile(userId: widget.userId, userType: widget.userType));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Adapts to dark/light mode
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share profile functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<SeeProfileBloc, SeeProfileState>(
        builder: (context, state) {
          final screenSize = MediaQuery.of(context).size;

          if (state is UserProfileLoading) {
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                size: 20,
              ),
            );
          }
          if (state is UserProfileError) {
            return CustomErrorScreen(
              message: state.message,
              onRetry: () {
                BlocProvider.of<SeeProfileBloc>(context).add(FetchUserProfile(userId: widget.userId, userType: widget.userType));
              },
            );
          }
          if (state is UserProfileLoadedEmployer) {
            return _buildProfileView(state.employer, state.companyDetails, screenSize, context);
          }
          if (state is UserProfileLoadedCandidate) {
            return _buildProfileView(state.candidate, null, screenSize, context);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined, size: 48, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
                SizedBox(height: 16),
                Text('No profile data available', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileView(dynamic user, CompanyDetails? companyDetails, Size screenSize, BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildProfileHeader(user, companyDetails, screenSize, context),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: _buildStatsCard(user, screenSize, context),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.02),
                  _buildPersonalInfoCard(user, screenSize, context),
                  SizedBox(height: screenSize.height * 0.02),
                  if (companyDetails != null) _buildCompanyCard(companyDetails, screenSize, context),
                  if (user is Candidate && user.disabilityDetails.type.isNotEmpty)
                    _buildDisabilityCard(user.disabilityDetails, screenSize, context),
                  if (user is Candidate && user.education.isNotEmpty)
                    _buildEducationCard(user.education, screenSize, context),
                  if (user is Candidate && user.skills.isNotEmpty)
                    _buildSkillsCard(user.skills, screenSize, context),
                  if (user is Candidate && user.jobPreferences.industries.isNotEmpty)
                    _buildJobPreferencesCard(user.jobPreferences, screenSize, context),
                  SizedBox(height: screenSize.height * 0.04),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(dynamic user, CompanyDetails? companyDetails, Size screenSize, BuildContext context) {
    // final String currentUserId = "your-logged-in-user-id";
    // final String currentUserType = "your-logged-in-user-type";
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.03),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'profile',
                  child: Container(
                    width: screenSize.width * 0.25,
                    height: screenSize.width * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.personalInfo.profilePic ?? 'default-profile-pic-url',
                        placeholder: (context, url) => CircularProgressIndicator(color: Theme.of(context).primaryColor),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: screenSize.width * 0.15,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenSize.width * 0.04),
                Expanded(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.personalInfo.fullName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: screenSize.width * 0.06,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.auth.verified)
                            Icon(Icons.verified, color: Colors.white, size: screenSize.width * 0.05),
                        ],
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        companyDetails != null ? companyDetails.companyName : 'Candidate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screenSize.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: user.auth.verified ? Colors.green : Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.auth.verified ? Icons.check_circle : Icons.cancel,
                                  size: screenSize.width * 0.035,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  user.auth.verified ? 'Verified' : 'Unverified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width * 0.035,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => ChatBloc(
                                      ChatRepository(),
                                      user.id, // receiverId
                                      widget.userType, // receiverType
                                      widget.currentUserId, // Correct currentUserId
                                      widget.currentUserType,
                                    ),
                                    child: ChatScreen(
                                      receiverId: user.id,
                                      receiverType: widget.userType,
                                      receiverName: user.personalInfo.fullName,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.message, size: screenSize.width * 0.04,color: Colors.white,),
                            label: Text(
                              'Message',
                              style: TextStyle(fontSize: screenSize.width * 0.035),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          if (user.about.isNotEmpty)
            Container(
              width: screenSize.width * 0.9,
              margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user.about,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.035,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: screenSize.height * 0.01),
        ],
      ),
    );
  }

  Widget _buildStatsCard(dynamic user, Size screenSize, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Adapts to dark/light mode
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Stories', user.stories.myStoryIds.length.toString(), Icons.auto_stories, screenSize, context),
          _buildDivider(context),
          _buildStatItem('Saved', user.stories.savedStoryIds.length.toString(), Icons.bookmark, screenSize, context),
          _buildDivider(context),
          if (user is Employer)
            _buildStatItem('Jobs', user.postedJobs.length.toString(), Icons.work, screenSize, context)
          else if (user is Candidate)
            _buildStatItem('Skills', user.skills.length.toString(), Icons.psychology, screenSize, context),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.3),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Size screenSize, BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: screenSize.width * 0.06,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: screenSize.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: screenSize.width * 0.035,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(dynamic user, Size screenSize, BuildContext context) {
    return _buildCard(
      title: 'Personal Information',
      icon: Icons.person,
      screenSize: screenSize,
      context: context,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.email, 'Email', user.personalInfo.email, screenSize, context),
          _buildInfoRow(Icons.phone, 'Phone', user.personalInfo.phoneNumber, screenSize, context),
          if (user.personalInfo.dob != null && user.personalInfo.dob.isNotEmpty)
            _buildInfoRow(
              Icons.cake,
              'DOB',
              DateFormat('MMM dd, yyyy').format(DateTime.parse(user.personalInfo.dob)),
              screenSize,
              context,
            ),
          if (user.personalInfo.address.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Address', user.personalInfo.address, screenSize, context),
          if (user.personalInfo.gender.isNotEmpty)
            _buildInfoRow(Icons.person_outline, 'Gender', user.personalInfo.gender, screenSize, context),
          if (user is Employer && user.companyDetails.designation.isNotEmpty)
            _buildInfoRow(Icons.work, 'Designation', user.companyDetails.designation, screenSize, context),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(CompanyDetails company, Size screenSize, BuildContext context) {
    return _buildCard(
      title: 'Company Details',
      icon: Icons.business,
      screenSize: screenSize,
      context: context,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: screenSize.width * 0.15,
                  height: screenSize.width * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: company.companyLogo,
                      placeholder: (context, url) => CircularProgressIndicator(color: Theme.of(context).primaryColor),
                      errorWidget: (context, url, error) => Icon(
                        Icons.business,
                        size: 30,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: screenSize.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.companyName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: screenSize.width * 0.045,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          company.industryType,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildInfoRow(Icons.email, 'Email', company.email, screenSize, context),
          _buildInfoRow(Icons.language, 'Website', company.website, screenSize, context),
          _buildInfoRow(Icons.info, 'About', company.about, screenSize, context),
          _buildInfoRow(
            Icons.location_city,
            'Location',
            '${company.location.city}, ${company.location.state}, ${company.location.country}',
            screenSize,
            context,
          ),
          _buildInfoRow(Icons.people, 'Employee Strength', company.employerStrengths, screenSize, context),
          _buildInfoRow(Icons.home_work, 'Official Address', company.officialAddress, screenSize, context),
        ],
      ),
    );
  }

  Widget _buildDisabilityCard(DisabilityDetails details, Size screenSize, BuildContext context) {
    return _buildCard(
      title: 'Disability Details',
      icon: Icons.accessibility_new,
      screenSize: screenSize,
      context: context,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.category, 'Type', details.type, screenSize, context),
          _buildInfoRow(Icons.percent, 'Percentage', '${details.percentage}%', screenSize, context),
          _buildInfoRow(Icons.card_membership, 'Certificate', details.certificateNumber, screenSize, context),
        ],
      ),
    );
  }

  Widget _buildEducationCard(List<Education> education, Size screenSize, BuildContext context) {
    return _buildCard(
      title: 'Education',
      icon: Icons.school,
      screenSize: screenSize,
      context: context,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: education.map((edu) => Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school, color: Theme.of(context).primaryColor, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${edu.degree} in ${edu.course}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          edu.institution,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${edu.startingYear.split('-')[0]} - ${edu.passingYear}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: screenSize.width * 0.035,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'CGPA: ${edu.cgpa}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.w500,
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSkillsCard(List<String> skills, Size screenSize, BuildContext context) {
    return _buildCard(
      title: 'Skills',
      icon: Icons.psychology,
      screenSize: screenSize,
      context: context,
      content: Wrap(
        spacing: screenSize.width * 0.02,
        runSpacing: screenSize.height * 0.01,
        children: skills.map((skill) => Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            skill,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: screenSize.width * 0.035,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildJobPreferencesCard(JobPreferences prefs, Size screenSize, BuildContext context) {
    return _buildCard(
      title: 'Job Preferences',
      icon: Icons.work_outline,
      screenSize: screenSize,
      context: context,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreferenceSection(
            'Industries',
            prefs.industries,
            Icons.business_center,
            screenSize,
            context,
          ),
          SizedBox(height: 12),
          _buildPreferenceSection(
            'Roles',
            prefs.roles,
            Icons.assignment_ind,
            screenSize,
            context,
          ),
          SizedBox(height: 12),
          _buildInfoRow(Icons.attach_money, 'Expected Salary', '\$${prefs.preferredSalary}', screenSize, context),
          _buildInfoRow(Icons.location_on, 'Preferred Locations', prefs.location.join(', '), screenSize, context),
          if (prefs.workMode.isNotEmpty)
            _buildInfoRow(Icons.computer, 'Work Mode', prefs.workMode, screenSize, context),
          if (prefs.experienceLevel.isNotEmpty)
            _buildInfoRow(Icons.timeline, 'Experience Level', prefs.experienceLevel, screenSize, context),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(
      String title, List<String> items, IconData icon, Size screenSize, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.04,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: screenSize.width * 0.02,
          runSpacing: screenSize.height * 0.01,
          children: items.map((item) => Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: screenSize.width * 0.035,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Size screenSize,
    required BuildContext context,
    required Widget content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Adapts to dark/light mode
        borderRadius: BorderRadius.circular(15),
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.width * 0.03,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: screenSize.width * 0.06,
                ),
                SizedBox(width: screenSize.width * 0.02),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.045,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Size screenSize, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.height * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: screenSize.width * 0.035,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: screenSize.width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}