import 'dart:ui';

import 'package:android/core/utils/snackBarUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';

import '../../../core/constants/colors.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../../data/models/candidate/candidate_model.dart';
import '../../../data/models/employer/employer_model.dart';
import '../bloc/candidate_profile_bloc.dart';

class CandidateProfile extends StatefulWidget {
  const CandidateProfile({super.key});

  @override
  State<CandidateProfile> createState() => _CandidateProfileState();
}

class _CandidateProfileState extends State<CandidateProfile> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CandidateProfileBloc>(context).add(FetchProfileData());
  }
  Future<void> _updateProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      try {
        File imageFile = File(image.path);
        Map<String, dynamic> personalInfo = {
          'profilePic': imageFile, // Replace with actual URL after upload
        };

        // BlocProvider.of<CandidateProfileBloc>(context).add(
        //     UpdatePersonalInfoDialog(personalInfo)
        // );
        Navigator.pop(context);
      } catch (e) {
        SnackBarUtils.showRedSnackBar("Failed to Update Employer Profile picture", context);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return BlocConsumer<CandidateProfileBloc, CandidateProfileState>(
      listener: (context, state) {

        if(state is ProfileUpdateSuccess){

          SnackBarUtils.showGreenSnackBar(state.message, context);

        }
        if (state is ProfileError){
          SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
      },
      builder: (context, state) {
        if (state is ProfileDataLoading) {
          return Center(child: LoadingAnimationWidget.hexagonDots(color: Theme.of(context).brightness ==Brightness.dark ?AppColors.lightPrimary :AppColors.lightPrimary, size: 30),);

        } else if (state is ProfileDataLoaded) {

          return _buildLoadedState(context, state,screenSize);

        } else if (state is ProfileError) {
          return CustomErrorScreen(message: state.error,onRetry: (){
            BlocProvider.of<CandidateProfileBloc>(context).add(FetchProfileData());
          },);
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: screenSize.width * 0.15,
                color: Colors.grey,
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                'Please try again later',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );

  }
  Widget _buildLoadedState(BuildContext context, ProfileDataLoaded state,Size screenSize) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(state.candidate,screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildInfoCards(context,state,screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Candidate candidate,Size screenSize) {

    return SliverAppBar(
      expandedHeight: screenSize.height * 0.25,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.9],
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade800,
                    Colors.blue.shade700,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: Hero(
                              tag: 'profile_image',
                              child: CircleAvatar(
                                backgroundImage: candidate.personalInfo.profilePic != null
                                    ? NetworkImage(candidate.personalInfo.profilePic!)
                                    : AssetImage('assets/default_profile.png') as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _updateProfilePicture(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height*0.02),
                  Text(
                      candidate.personalInfo.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: screenSize.width*0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      )
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, ProfileDataLoaded state,Size screenSize) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildProfileSummarySection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildAboutSection(state.candidate,screenSize),
          SizedBox(height: screenSize.height*0.02),
          _buildDisabilityDetailsSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildJobPreferencesSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildSkillsSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildEducationSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildWorkExperienceSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildInternshipSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildProjectsSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildCertificationsSection(state.candidate),
          SizedBox(height: screenSize.height*0.02),
          _buildResumeSection(state.candidate),
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    final screenSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            title,
            style: Theme.of(context).textTheme.displaySmall
        ),
        IconButton(
          icon: Icon(Icons.add_circle, color: Colors.blue.shade600),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBackground, AppColors.lightSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [Theme.of(context).cardTheme.shadowColor != null ? BoxShadow(
          color: Theme.of(context).cardTheme.shadowColor!,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ) : const BoxShadow()],
      ),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: screenSize.width * 0.12,
                backgroundImage: candidate.personalInfo.profilePic != null
                    ? NetworkImage(candidate.personalInfo.profilePic!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                backgroundColor: AppColors.lightSurface,
              ),
              SizedBox(width: screenSize.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.personalInfo.fullName,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        //color: AppColors.lightText,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Text(
                      candidate.personalInfo.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                    Text(
                      candidate.personalInfo.phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showPersonalInfoEditDialog(context,candidate),
              icon:  Icon(FontAwesomeIcons.edit,color: Colors.white,),
              label:  Text('Edit'),
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.04,
                    vertical: screenSize.height * 0.015,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummarySection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Profile Summary',
                  style: Theme.of(context).textTheme.displaySmall
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                onPressed: () => _showProfileSummaryEditDialog(context,candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          Text(
            candidate.profileSummary.isNotEmpty
                ? candidate.profileSummary
                : 'No profile summary added yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: candidate.profileSummary.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: candidate.profileSummary.isEmpty ? AppColors.lightSecondaryText : null,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Candidate candidate,Size screenSize) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'About',
                  style: Theme.of(context).textTheme.displaySmall
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
                onPressed: () => _showAboutEditDialog(context,candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          Text(
            candidate.about.isNotEmpty
                ? candidate.about
                : 'Tell employers about yourself.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: candidate.profileSummary.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: candidate.profileSummary.isEmpty ? AppColors.lightSecondaryText : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabilityDetailsSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    final hasDisabilityInfo = candidate.disabilityDetails.type.isNotEmpty;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disability Details',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.lightText,
                ),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
                onPressed: () => _showDisabilityDetailsEditDialog(context,candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          if (hasDisabilityInfo) ...[
            _buildInfoRow('Type', candidate.disabilityDetails.type),
            _buildInfoRow('Percentage', '${candidate.disabilityDetails.percentage}%'),
            _buildInfoRow('Certificate No.', candidate.disabilityDetails.certificateNumber),
            if (candidate.disabilityDetails.accommodationsNeeded.isNotEmpty)
              _buildInfoRow('Accommodations', candidate.disabilityDetails.accommodationsNeeded.join(', ')),
            if (candidate.disabilityDetails.assistiveTechnology.isNotEmpty)
              _buildInfoRow('Assistive Tech', candidate.disabilityDetails.assistiveTechnology.join(', ')),
          ] else
            Text(
              'No disability details added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobPreferencesSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    final jp = candidate.jobPreferences;
    final hasJobPreferences = jp.industries.isNotEmpty || jp.roles.isNotEmpty || jp.preferredSalary > 0;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Job Preferences',
                  style: Theme.of(context).textTheme.displaySmall
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
                onPressed: () => _showJobPreferencesEditDialog(context,candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          if (hasJobPreferences) ...[
            if (jp.industries.isNotEmpty) _buildInfoRow('Industries', jp.industries.join(', ')),
            if (jp.roles.isNotEmpty) _buildInfoRow('Roles', jp.roles.join(', ')),
            if (jp.preferredSalary > 0) _buildInfoRow('Salary', '\$${jp.preferredSalary}'),
          ] else
            Text(
              'No job preferences set yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Skills',
                () => _showSkillsEditDialog(context,candidate),
          ),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.skills.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: candidate.skills.map((skill) => Chip(
                  label: Text(
                    skill,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.lightPrimary.withOpacity(0.2)),
                  ),
                  elevation: 1,
                  shadowColor: AppColors.lightText.withOpacity(0.1),
                )).toList(),
              ),
            )
          else
            Text(
              'No skills added yet. Tap + to add your skills.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildEducationSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Education', () => _showAddEducationDialog(context,candidate)),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.education.isEmpty)
            Text(
              'No education history added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidate.education.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final edu = candidate.education[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                  title: Text(
                    '${edu.degree} ${edu.course}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edu.institution, style: Theme.of(context).textTheme.bodyMedium),
                      Text('${edu.startingYear} - ${edu.passingYear}', style: Theme.of(context).textTheme.bodySmall),
                      if (edu.cgpa.isNotEmpty) Text('CGPA: ${edu.cgpa}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
                        onPressed: () => _showEditEducationDialog(context, edu),
                      ),
                      IconButton(
                        icon:  Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, 'education', edu.id, '${edu.degree} from ${edu.institution}'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWorkExperienceSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Work Experience', () => _showAddWorkExperienceDialog(context)),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.workExperience.isEmpty)
            Text(
              'No work experience added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidate.workExperience.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final exp = candidate.workExperience[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                  title: Text(
                    exp.position,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp.company, style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        exp.isCurrentlyWorking ? '${exp.startDate} - Present' : '${exp.startDate} - ${exp.endDate}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                        onPressed: () => _showEditWorkExperienceDialog(context, exp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, 'work-experience', exp.id, '${exp.position} at ${exp.company}'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInternshipSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Internships', () => _showAddInternshipDialog(context)),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.internships.isEmpty)
            Text(
              'No internships added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidate.internships.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final internship = candidate.internships[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                  title: Text(
                    internship.projectName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship.company,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        internship.isCurrentlyWorking ? '${internship.startDate} - Present' : '${internship.startDate} - ${internship.endDate}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                        onPressed: () => _showEditInternshipDialog(context, internship),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, 'internship', internship.id, '${internship.projectName} at ${internship.company}'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Projects', () => _showAddProjectDialog(context)),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.projects.isEmpty)
            Text(
              'No projects added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidate.projects.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final project = candidate.projects[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                  title: Text(
                    project.projectName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${project.startDate} - ${project.endDate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                        onPressed: () => _showEditProjectDialog(context, project),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, 'project', project.id, project.projectName),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Certifications', () => _showAddCertificationDialog(context)),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.certifications.isEmpty)
            Text(
              'No certifications added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.lightSecondaryText,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidate.certifications.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final cert = candidate.certifications[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                  title: Text(
                    cert.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    cert.issuingOrganization,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                        onPressed: () => _showEditCertificationDialog(context, cert),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, 'certification', cert.id, cert.name),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resume',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.lightText,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          if (candidate.resume.isNotEmpty)
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.description, color: AppColors.lightPrimary),
                  title: Text('Resume.pdf', style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('Tap to view', style: Theme.of(context).textTheme.bodySmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteResume(context),
                  ),
                  onTap: () {},
                ),
                ElevatedButton.icon(
                  onPressed: () => _uploadResume(context),
                  icon: const Icon(FontAwesomeIcons.upload,color: Colors.white,),
                  label: const Text('Replace Resume'),
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04,
                        vertical: screenSize.height * 0.015,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _uploadResume(context),
                icon: const Icon(Icons.upload_file,color: Colors.white,),
                label: const Text('Upload Resume'),
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.06,
                      vertical: screenSize.height * 0.02,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: Theme.of(context).cardTheme.shape is RoundedRectangleBorder
            ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius
            : BorderRadius.circular(16),
        boxShadow: [Theme.of(context).cardTheme.shadowColor != null ? BoxShadow(
          color: Theme.of(context).cardTheme.shadowColor!,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ) : const BoxShadow()],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenSize.width * 0.35, // Responsive width for label
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.lightText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfoEditDialog(BuildContext parentContext,Candidate candidate) {
    final nameController = TextEditingController(text: candidate.personalInfo.fullName);
    final emailController = TextEditingController(text: candidate.personalInfo.email);
    final phoneController = TextEditingController(text: candidate.personalInfo.phoneNumber);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Personal Information', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedInfo = PersonalInfo(
                fullName: nameController.text,
                email: emailController.text,
                phoneNumber: phoneController.text,
                profilePic: candidate.personalInfo.profilePic, // Preserve existing pic
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateProfile(updatedInfo));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileSummaryEditDialog(BuildContext parentContext,Candidate candidate) {
    final controller = TextEditingController(text: candidate.profileSummary);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profile Summary', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Write a brief summary...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.lightSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateProfileSummary(controller.text));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutEditDialog(BuildContext parentContext,Candidate candidate) {
    final controller = TextEditingController(text: candidate.about);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit About', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Tell employers about yourself...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.lightSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateAbout(controller.text));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDisabilityDetailsEditDialog(BuildContext parentContext,Candidate candidate) {
    final typeController = TextEditingController(text: candidate.disabilityDetails.type);
    final percentageController = TextEditingController(text: candidate.disabilityDetails.percentage.toString());
    final certController = TextEditingController(text: candidate.disabilityDetails.certificateNumber);
    final accommodationsController = TextEditingController(text: candidate.disabilityDetails.accommodationsNeeded.join(', '));
    final techController = TextEditingController(text: candidate.disabilityDetails.assistiveTechnology.join(', '));
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Disability Details', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Disability Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: percentageController,
                decoration: InputDecoration(
                  labelText: 'Percentage (%)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: certController,
                decoration: InputDecoration(
                  labelText: 'Certificate Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: accommodationsController,
                decoration: InputDecoration(
                  labelText: 'Accommodations Needed (comma-separated)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: techController,
                decoration: InputDecoration(
                  labelText: 'Assistive Technology (comma-separated)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedDetails = DisabilityDetails(
                type: typeController.text,
                percentage: int.tryParse(percentageController.text) ?? 0,
                certificateNumber: certController.text,
                accommodationsNeeded: accommodationsController.text.split(',').map((e) => e.trim()).toList(),
                assistiveTechnology: techController.text.split(',').map((e) => e.trim()).toList(),
              );
              // BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateDisabilityDetails(updatedDetails));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showJobPreferencesEditDialog(BuildContext parentContext,Candidate candidate) {
    final jp = candidate.jobPreferences;
    final industriesController = TextEditingController(text: jp.industries.join(', '));
    final rolesController = TextEditingController(text: jp.roles.join(', '));
    final salaryController = TextEditingController(text: jp.preferredSalary.toString());
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Job Preferences', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: industriesController,
                decoration: InputDecoration(
                  labelText: 'Industries (comma-separated)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: rolesController,
                decoration: InputDecoration(
                  labelText: 'Roles (comma-separated)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: salaryController,
                decoration: InputDecoration(
                  labelText: 'Preferred Salary',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedPrefs = JobPreferences(
                industries: industriesController.text.split(',').map((e) => e.trim()).toList(),
                roles: rolesController.text.split(',').map((e) => e.trim()).toList(),
                preferredSalary: int.tryParse(salaryController.text) ?? 0,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateJobPreferences(updatedPrefs));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSkillsEditDialog(BuildContext parentContext,Candidate candidate) {
    final TextEditingController skillController = TextEditingController();
    List<String> tempSkills = List.from(candidate.skills);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Skills', style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SizedBox(
            width: screenSize.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: skillController,
                    decoration: InputDecoration(
                      hintText: 'Enter a skill (e.g., Flutter, Java)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: AppColors.lightPrimary),
                        onPressed: () {
                          final skill = skillController.text.trim();
                          if (skill.isNotEmpty && !tempSkills.contains(skill)) {
                            setState(() {
                              tempSkills.add(skill);
                              skillController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  if (tempSkills.isNotEmpty) ...[
                    Text(
                      'Your Skills',
                      style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightText,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempSkills.map((skill) => Chip(
                        label: Text(
                          skill,
                          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightPrimary,
                          ),
                        ),
                        backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                        deleteIcon: Icon(Icons.close, size: 18, color: AppColors.lightPrimary),
                        onDeleted: () {
                          setState(() => tempSkills.remove(skill));
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateSkills(tempSkills));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEducationDialog(BuildContext parentContext,Candidate candidate) {
    final degreeController = TextEditingController();
    final courseController = TextEditingController();
    final institutionController = TextEditingController();
    final startYearController = TextEditingController();
    final passingYearController = TextEditingController();
    final cgpaController = TextEditingController();
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Education', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: degreeController,
                decoration: InputDecoration(
                  labelText: 'Degree',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: courseController,
                decoration: InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: institutionController,
                decoration: InputDecoration(
                  labelText: 'Institution',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: startYearController,
                decoration: InputDecoration(
                  labelText: 'Start Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: passingYearController,
                decoration: InputDecoration(
                  labelText: 'Passing Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: cgpaController,
                decoration: InputDecoration(
                  labelText: 'CGPA (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final newEducation = Education(
                id: DateTime.now().toString(), // Temporary ID, replace with server-generated ID
                degree: degreeController.text,
                course: courseController.text,
                institution: institutionController.text,
                startingYear: startYearController.text,
                passingYear: int.parse(passingYearController.text),
                cgpa: cgpaController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddEducation(newEducation));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditEducationDialog(BuildContext parentContext, Education education) {
    final degreeController = TextEditingController(text: education.degree);
    final courseController = TextEditingController(text: education.course);
    final institutionController = TextEditingController(text: education.institution);
    final startYearController = TextEditingController(text: education.startingYear);
    final passingYearController = TextEditingController(text: education.passingYear.toString());
    final cgpaController = TextEditingController(text: education.cgpa);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Education', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: degreeController,
                decoration: InputDecoration(
                  labelText: 'Degree',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: courseController,
                decoration: InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: institutionController,
                decoration: InputDecoration(
                  labelText: 'Institution',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: startYearController,
                decoration: InputDecoration(
                  labelText: 'Start Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: passingYearController,
                decoration: InputDecoration(
                  labelText: 'Passing Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: cgpaController,
                decoration: InputDecoration(
                  labelText: 'CGPA (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedEducation = Education(
                id: education.id,
                degree: degreeController.text,
                course: courseController.text,
                institution: institutionController.text,
                startingYear: startYearController.text,
                passingYear: int.parse(passingYearController.text),
                cgpa: cgpaController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateEducation(updatedEducation));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddWorkExperienceDialog(BuildContext parentContext) {
    final positionController = TextEditingController();
    final companyController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    bool isCurrentlyWorking = false;
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Work Experience', style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: positionController,
                  decoration: InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (e.g., Jan 2020)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                if (!isCurrentlyWorking)
                  TextField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date (e.g., Dec 2021)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                    ),
                  ),
                SizedBox(height: screenSize.height * 0.015),
                CheckboxListTile(
                  title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
                  value: isCurrentlyWorking,
                  onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
                  activeColor: AppColors.lightPrimary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final newExperience = WorkExperience(
                  id: DateTime.now().toString(), // Temporary ID
                  position: positionController.text,
                  company: companyController.text,
                  startDate: startDateController.text,
                  endDate: isCurrentlyWorking ? '' : endDateController.text,
                  isCurrentlyWorking: isCurrentlyWorking,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddWorkExperience(newExperience));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWorkExperienceDialog(BuildContext parentContext, WorkExperience experience) {
    final positionController = TextEditingController(text: experience.position);
    final companyController = TextEditingController(text: experience.company);
    final startDateController = TextEditingController(text: experience.startDate);
    final endDateController = TextEditingController(text: experience.endDate);
    bool isCurrentlyWorking = experience.isCurrentlyWorking;
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Work Experience', style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: positionController,
                  decoration: InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (e.g., Jan 2020)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                if (!isCurrentlyWorking)
                  TextField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date (e.g., Dec 2021)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                    ),
                  ),
                SizedBox(height: screenSize.height * 0.015),
                CheckboxListTile(
                  title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
                  value: isCurrentlyWorking,
                  onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
                  activeColor: AppColors.lightPrimary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedExperience = WorkExperience(
                  id: experience.id,
                  position: positionController.text,
                  company: companyController.text,
                  startDate: startDateController.text,
                  endDate: isCurrentlyWorking ? '' : endDateController.text,
                  isCurrentlyWorking: isCurrentlyWorking,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateWorkExperience(updatedExperience));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,

                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  void _showAddInternshipDialog(BuildContext parentContext) {
    final projectNameController = TextEditingController();
    final companyController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    bool isCurrentlyWorking = false;
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Internship', style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: projectNameController,
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (e.g., Jan 2020)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                if (!isCurrentlyWorking)
                  TextField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date (e.g., Dec 2021)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                    ),
                  ),
                SizedBox(height: screenSize.height * 0.015),
                CheckboxListTile(
                  title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
                  value: isCurrentlyWorking,
                  onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
                  activeColor: AppColors.lightPrimary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final newInternship = Internship(
                  id: DateTime.now().toString(), // Temporary ID
                  projectName: projectNameController.text,
                  company: companyController.text,
                  startDate: startDateController.text,
                  endDate: isCurrentlyWorking ? '' : endDateController.text,
                  isCurrentlyWorking: isCurrentlyWorking,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddInternship(newInternship));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  void _showEditInternshipDialog(BuildContext parentContext, Internship internship) {
    final projectNameController = TextEditingController(text: internship.projectName);
    final companyController = TextEditingController(text: internship.company);
    final startDateController = TextEditingController(text: internship.startDate);
    final endDateController = TextEditingController(text: internship.endDate);
    bool isCurrentlyWorking = internship.isCurrentlyWorking;
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Internship', style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: projectNameController,
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (e.g., Jan 2020)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.lightSurface,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                if (!isCurrentlyWorking)
                  TextField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date (e.g., Dec 2021)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                    ),
                  ),
                SizedBox(height: screenSize.height * 0.015),
                CheckboxListTile(
                  title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
                  value: isCurrentlyWorking,
                  onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
                  activeColor: AppColors.lightPrimary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedInternship = Internship(
                  id: internship.id,
                  projectName: projectNameController.text,
                  company: companyController.text,
                  startDate: startDateController.text,
                  endDate: isCurrentlyWorking ? '' : endDateController.text,
                  isCurrentlyWorking: isCurrentlyWorking,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateInternship(updatedInternship));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  void _showAddProjectDialog(BuildContext parentContext) {
    final projectNameController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Project', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: projectNameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date (e.g., Jan 2020)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date (e.g., Dec 2021)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final newProject = Project(
                id: DateTime.now().toString(), // Temporary ID
                projectName: projectNameController.text,
                startDate: startDateController.text,
                endDate: endDateController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddProject(newProject));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showEditProjectDialog(BuildContext parentContext, Project project) {
    final projectNameController = TextEditingController(text: project.projectName);
    final startDateController = TextEditingController(text: project.startDate);
    final endDateController = TextEditingController(text: project.endDate);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Project', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: projectNameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date (e.g., Jan 2020)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date (e.g., Dec 2021)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProject = Project(
                id: project.id,
                projectName: projectNameController.text,
                startDate: startDateController.text,
                endDate: endDateController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateProject(updatedProject));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showAddCertificationDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final orgController = TextEditingController();
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Certification', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Certification Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: orgController,
                decoration: InputDecoration(
                  labelText: 'Issuing Organization',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final newCertification = Certification(
                id: DateTime.now().toString(), // Temporary ID
                name: nameController.text,
                issuingOrganization: orgController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddCertification(newCertification));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showEditCertificationDialog(BuildContext parentContext, Certification certification) {
    final nameController = TextEditingController(text: certification.name);
    final orgController = TextEditingController(text: certification.issuingOrganization);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Certification', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Certification Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.015),
              TextField(
                controller: orgController,
                decoration: InputDecoration(
                  labelText: 'Issuing Organization',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedCertification = Certification(
                id: certification.id,
                name: nameController.text,
                issuingOrganization: orgController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateCertification(updatedCertification));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _uploadResume(BuildContext parentContext) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      // BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateResume(file.path));
    }
  }

  void _confirmDelete(BuildContext parentContext, String type, String id, String itemName) {
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Delete', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: Text('Are you sure you want to delete "$itemName"?', style: Theme.of(dialogContext).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              switch (type) {
                case 'education':
                  BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteEducation(id));
                  break;
                case 'work-experience':
                  BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteWorkExperience(id));
                  break;
                case 'internship':
                  BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteInternship(id));
                  break;
                case 'project':
                  BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteProject(id));
                  break;
                case 'certification':
                  BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteCertification(id));
                  break;
              }
              Navigator.pop(dialogContext);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _confirmDeleteResume(BuildContext parentContext) {
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Delete', style: Theme.of(dialogContext).textTheme.displaySmall),
        content: Text('Are you sure you want to delete your resume?', style: Theme.of(dialogContext).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteResume());
              Navigator.pop(dialogContext);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// class ProfileContent extends StatefulWidget {
//   final Candidate candidate;
//
//   const ProfileContent({super.key, required this.candidate});
//
//   @override
//   State<ProfileContent> createState() => _ProfileContentState();
// }
//
// class _ProfileContentState extends State<ProfileContent> {
//
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.of(context).size;
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildPersonalInfoSection(),
//            SizedBox(height: screenSize.height*0.02),
//           _buildProfileSummarySection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildAboutSection(screenSize),
//           SizedBox(height: screenSize.height*0.02),
//           _buildDisabilityDetailsSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildJobPreferencesSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildSkillsSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildEducationSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildWorkExperienceSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildInternshipSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildProjectsSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildCertificationsSection(),
//           SizedBox(height: screenSize.height*0.02),
//           _buildResumeSection(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, VoidCallback onAdd) {
//     final screenSize = MediaQuery.of(context).size;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//             style: Theme.of(context).textTheme.displaySmall
//         ),
//         IconButton(
//           icon: Icon(Icons.add_circle, color: Colors.blue.shade600),
//           onPressed: onAdd,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPersonalInfoSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.lightBackground, AppColors.lightSurface],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [Theme.of(context).cardTheme.shadowColor != null ? BoxShadow(
//           color: Theme.of(context).cardTheme.shadowColor!,
//           blurRadius: 10,
//           offset: const Offset(0, 5),
//         ) : const BoxShadow()],
//       ),
//       padding: EdgeInsets.all(screenSize.width * 0.04),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: screenSize.width * 0.12,
//                 backgroundImage: widget.candidate.personalInfo.profilePic != null
//                     ? NetworkImage(widget.candidate.personalInfo.profilePic!)
//                     : AssetImage('assets/default_profile.png') as ImageProvider,
//                 backgroundColor: AppColors.lightSurface,
//               ),
//               SizedBox(width: screenSize.width * 0.04),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.candidate.personalInfo.fullName,
//                       style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         //color: AppColors.lightText,
//                       ),
//                     ),
//                     SizedBox(height: screenSize.height * 0.01),
//                     Text(
//                         widget.candidate.personalInfo.email,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppColors.lightSecondaryText,
//                       ),
//                     ),
//                     Text(
//                       widget.candidate.personalInfo.phoneNumber,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppColors.lightSecondaryText,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: screenSize.height * 0.02),
//           Align(
//             alignment: Alignment.centerRight,
//             child: ElevatedButton.icon(
//               onPressed: () => _showPersonalInfoEditDialog(context),
//               icon:  Icon(FontAwesomeIcons.edit,color: Colors.white,),
//               label:  Text('Edit'),
//               style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
//                 padding: MaterialStateProperty.all(
//                   EdgeInsets.symmetric(
//                     horizontal: screenSize.width * 0.04,
//                     vertical: screenSize.height * 0.015,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfileSummarySection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Profile Summary',
//                 style: Theme.of(context).textTheme.displaySmall
//               ),
//               IconButton(
//                 icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
//                 onPressed: () => _showProfileSummaryEditDialog(context),
//               ),
//             ],
//           ),
//           SizedBox(height: screenSize.height * 0.015),
//           Text(
//             widget.candidate.profileSummary.isNotEmpty
//                 ? widget.candidate.profileSummary
//                 : 'No profile summary added yet.',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontStyle: widget.candidate.profileSummary.isEmpty ? FontStyle.italic : FontStyle.normal,
//               color: widget.candidate.profileSummary.isEmpty ? AppColors.lightSecondaryText : null,
//             ),
//             maxLines: 5,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAboutSection(Size screenSize) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'About',
//                   style: Theme.of(context).textTheme.displaySmall
//               ),
//               IconButton(
//                 icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
//                 onPressed: () => _showAboutEditDialog(context),
//               ),
//             ],
//           ),
//           SizedBox(height: screenSize.height * 0.015),
//           Text(
//             widget.candidate.about.isNotEmpty
//                 ? widget.candidate.about
//                 : 'Tell employers about yourself.',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontStyle: widget.candidate.profileSummary.isEmpty ? FontStyle.italic : FontStyle.normal,
//               color: widget.candidate.profileSummary.isEmpty ? AppColors.lightSecondaryText : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDisabilityDetailsSection() {
//     final screenSize = MediaQuery.of(context).size;
//     final hasDisabilityInfo = widget.candidate.disabilityDetails.type.isNotEmpty;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Disability Details',
//                 style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                   color: AppColors.lightText,
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
//                 onPressed: () => _showDisabilityDetailsEditDialog(context),
//               ),
//             ],
//           ),
//           SizedBox(height: screenSize.height * 0.015),
//           if (hasDisabilityInfo) ...[
//             _buildInfoRow('Type', widget.candidate.disabilityDetails.type),
//             _buildInfoRow('Percentage', '${widget.candidate.disabilityDetails.percentage}%'),
//             _buildInfoRow('Certificate No.', widget.candidate.disabilityDetails.certificateNumber),
//             if (widget.candidate.disabilityDetails.accommodationsNeeded.isNotEmpty)
//               _buildInfoRow('Accommodations', widget.candidate.disabilityDetails.accommodationsNeeded.join(', ')),
//             if (widget.candidate.disabilityDetails.assistiveTechnology.isNotEmpty)
//               _buildInfoRow('Assistive Tech', widget.candidate.disabilityDetails.assistiveTechnology.join(', ')),
//           ] else
//             Text(
//               'No disability details added yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: Colors.grey,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildJobPreferencesSection() {
//     final screenSize = MediaQuery.of(context).size;
//     final jp = widget.candidate.jobPreferences;
//     final hasJobPreferences = jp.industries.isNotEmpty || jp.roles.isNotEmpty || jp.preferredSalary > 0;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Job Preferences',
//                 style: Theme.of(context).textTheme.displaySmall
//               ),
//               IconButton(
//                 icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
//                 onPressed: () => _showJobPreferencesEditDialog(context),
//               ),
//             ],
//           ),
//           SizedBox(height: screenSize.height * 0.015),
//           if (hasJobPreferences) ...[
//             if (jp.industries.isNotEmpty) _buildInfoRow('Industries', jp.industries.join(', ')),
//             if (jp.roles.isNotEmpty) _buildInfoRow('Roles', jp.roles.join(', ')),
//             if (jp.preferredSalary > 0) _buildInfoRow('Salary', '\$${jp.preferredSalary}'),
//           ] else
//             Text(
//               'No job preferences set yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSkillsSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader(
//             'Skills',
//                 () => _showSkillsEditDialog(context),
//           ),
//           SizedBox(height: screenSize.height * 0.015),
//           if (widget.candidate.skills.isNotEmpty)
//             Container(
//               constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: widget.candidate.skills.map((skill) => Chip(
//                   label: Text(
//                     skill,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.lightPrimary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide(color: AppColors.lightPrimary.withOpacity(0.2)),
//                   ),
//                   elevation: 1,
//                   shadowColor: AppColors.lightText.withOpacity(0.1),
//                 )).toList(),
//               ),
//             )
//           else
//             Text(
//               'No skills added yet. Tap + to add your skills.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//
//
//   Widget _buildEducationSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Education', () => _showAddEducationDialog(context)),
//           SizedBox(height: screenSize.height * 0.015),
//           if (widget.candidate.education.isEmpty)
//             Text(
//               'No education history added yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.candidate.education.length,
//               separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
//               itemBuilder: (context, index) {
//                 final edu = widget.candidate.education[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
//                   title: Text(
//                     '${edu.degree} ${edu.course}',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.lightText,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(edu.institution, style: Theme.of(context).textTheme.bodyMedium),
//                       Text('${edu.startingYear} - ${edu.passingYear}', style: Theme.of(context).textTheme.bodySmall),
//                       if (edu.cgpa.isNotEmpty) Text('CGPA: ${edu.cgpa}', style: Theme.of(context).textTheme.bodySmall),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(FontAwesomeIcons.edit,  color: AppColors.lightPrimary),
//                         onPressed: () => _showEditEducationDialog(context, edu),
//                       ),
//                       IconButton(
//                         icon:  Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _confirmDelete(context, 'education', edu.id, '${edu.degree} from ${edu.institution}'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWorkExperienceSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Work Experience', () => _showAddWorkExperienceDialog(context)),
//           SizedBox(height: screenSize.height * 0.015),
//           if (widget.candidate.workExperience.isEmpty)
//             Text(
//               'No work experience added yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.candidate.workExperience.length,
//               separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
//               itemBuilder: (context, index) {
//                 final exp = widget.candidate.workExperience[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
//                   title: Text(
//                     exp.position,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.lightText,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(exp.company, style: Theme.of(context).textTheme.bodyMedium),
//                       Text(
//                         exp.isCurrentlyWorking ? '${exp.startDate} - Present' : '${exp.startDate} - ${exp.endDate}',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
//                         onPressed: () => _showEditWorkExperienceDialog(context, exp),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _confirmDelete(context, 'work-experience', exp.id, '${exp.position} at ${exp.company}'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInternshipSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Internships', () => _showAddInternshipDialog(context)),
//           SizedBox(height: screenSize.height * 0.015),
//           if (widget.candidate.internships.isEmpty)
//             Text(
//               'No internships added yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.candidate.internships.length,
//               separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
//               itemBuilder: (context, index) {
//                 final internship = widget.candidate.internships[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
//                   title: Text(
//                     internship.projectName,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.lightText,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         internship.company,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                       Text(
//                         internship.isCurrentlyWorking ? '${internship.startDate} - Present' : '${internship.startDate} - ${internship.endDate}',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
//                         onPressed: () => _showEditInternshipDialog(context, internship),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _confirmDelete(context, 'internship', internship.id, '${internship.projectName} at ${internship.company}'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProjectsSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Projects', () => _showAddProjectDialog(context)),
//           SizedBox(height: screenSize.height * 0.015),
//           if (widget.candidate.projects.isEmpty)
//             Text(
//               'No projects added yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.candidate.projects.length,
//               separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
//               itemBuilder: (context, index) {
//                 final project = widget.candidate.projects[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
//                   title: Text(
//                     project.projectName,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.lightText,
//                     ),
//                   ),
//                   subtitle: Text(
//                     '${project.startDate} - ${project.endDate}',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
//                         onPressed: () => _showEditProjectDialog(context, project),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _confirmDelete(context, 'project', project.id, project.projectName),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCertificationsSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Certifications', () => _showAddCertificationDialog(context)),
//           SizedBox(height: screenSize.height * 0.015),
//           if (widget.candidate.certifications.isEmpty)
//             Text(
//               'No certifications added yet.',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: AppColors.lightSecondaryText,
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.candidate.certifications.length,
//               separatorBuilder: (context, index) => Divider(color: AppColors.lightDivider),
//               itemBuilder: (context, index) {
//                 final cert = widget.candidate.certifications[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
//                   title: Text(
//                     cert.name,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.lightText,
//                     ),
//                   ),
//                   subtitle: Text(
//                     cert.issuingOrganization,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
//                         onPressed: () => _showEditCertificationDialog(context, cert),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _confirmDelete(context, 'certification', cert.id, cert.name),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResumeSection() {
//     final screenSize = MediaQuery.of(context).size;
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Resume',
//             style: Theme.of(context).textTheme.displaySmall?.copyWith(
//               color: AppColors.lightText,
//             ),
//           ),
//           SizedBox(height: screenSize.height * 0.02),
//           if (widget.candidate.resume.isNotEmpty)
//             Column(
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.description, color: AppColors.lightPrimary),
//                   title: Text('Resume.pdf', style: Theme.of(context).textTheme.bodyLarge),
//                   subtitle: Text('Tap to view', style: Theme.of(context).textTheme.bodySmall),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => _confirmDeleteResume(context),
//                   ),
//                   onTap: () {},
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _uploadResume(context),
//                   icon: const Icon(FontAwesomeIcons.upload,color: Colors.white,),
//                   label: const Text('Replace Resume'),
//                   style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
//                     padding: MaterialStateProperty.all(
//                       EdgeInsets.symmetric(
//                         horizontal: screenSize.width * 0.04,
//                         vertical: screenSize.height * 0.015,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           else
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: () => _uploadResume(context),
//                 icon: const Icon(Icons.upload_file,color: Colors.white,),
//                 label: const Text('Upload Resume'),
//                 style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
//                   padding: MaterialStateProperty.all(
//                     EdgeInsets.symmetric(
//                       horizontal: screenSize.width * 0.06,
//                       vertical: screenSize.height * 0.02,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard({required Widget child}) {
//     final screenSize = MediaQuery.of(context).size;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
//       padding: EdgeInsets.all(screenSize.width * 0.04),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardTheme.color,
//         borderRadius: Theme.of(context).cardTheme.shape is RoundedRectangleBorder
//             ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius
//             : BorderRadius.circular(16),
//         boxShadow: [Theme.of(context).cardTheme.shadowColor != null ? BoxShadow(
//           color: Theme.of(context).cardTheme.shadowColor!,
//           blurRadius: 10,
//           offset: const Offset(0, 5),
//         ) : const BoxShadow()],
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     final screenSize = MediaQuery.of(context).size;
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.005),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: screenSize.width * 0.35, // Responsive width for label
//             child: Text(
//               '$label:',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.lightPrimary,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.lightText,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPersonalInfoEditDialog(BuildContext parentContext) {
//     final nameController = TextEditingController(text: widget.candidate.personalInfo.fullName);
//     final emailController = TextEditingController(text: widget.candidate.personalInfo.email);
//     final phoneController = TextEditingController(text: widget.candidate.personalInfo.phoneNumber);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Personal Information', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final updatedInfo = PersonalInfo(
//                 fullName: nameController.text,
//                 email: emailController.text,
//                 phoneNumber: phoneController.text,
//                 profilePic: widget.candidate.personalInfo.profilePic, // Preserve existing pic
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateProfile(updatedInfo));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showProfileSummaryEditDialog(BuildContext parentContext) {
//     final controller = TextEditingController(text: widget.candidate.profileSummary);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Profile Summary', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: TextField(
//           controller: controller,
//           maxLines: 5,
//           decoration: InputDecoration(
//             hintText: 'Write a brief summary...',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: AppColors.lightSurface,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateProfileSummary(controller.text));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAboutEditDialog(BuildContext parentContext) {
//     final controller = TextEditingController(text: widget.candidate.about);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit About', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: TextField(
//           controller: controller,
//           maxLines: 8,
//           decoration: InputDecoration(
//             hintText: 'Tell employers about yourself...',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: AppColors.lightSurface,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateAbout(controller.text));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDisabilityDetailsEditDialog(BuildContext parentContext) {
//     final typeController = TextEditingController(text: widget.candidate.disabilityDetails.type);
//     final percentageController = TextEditingController(text: widget.candidate.disabilityDetails.percentage.toString());
//     final certController = TextEditingController(text: widget.candidate.disabilityDetails.certificateNumber);
//     final accommodationsController = TextEditingController(text: widget.candidate.disabilityDetails.accommodationsNeeded.join(', '));
//     final techController = TextEditingController(text: widget.candidate.disabilityDetails.assistiveTechnology.join(', '));
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Disability Details', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: typeController,
//                 decoration: InputDecoration(
//                   labelText: 'Disability Type',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: percentageController,
//                 decoration: InputDecoration(
//                   labelText: 'Percentage (%)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: certController,
//                 decoration: InputDecoration(
//                   labelText: 'Certificate Number',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: accommodationsController,
//                 decoration: InputDecoration(
//                   labelText: 'Accommodations Needed (comma-separated)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: techController,
//                 decoration: InputDecoration(
//                   labelText: 'Assistive Technology (comma-separated)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final updatedDetails = DisabilityDetails(
//                 type: typeController.text,
//                 percentage: int.tryParse(percentageController.text) ?? 0,
//                 certificateNumber: certController.text,
//                 accommodationsNeeded: accommodationsController.text.split(',').map((e) => e.trim()).toList(),
//                 assistiveTechnology: techController.text.split(',').map((e) => e.trim()).toList(),
//               );
//              // BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateDisabilityDetails(updatedDetails));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//   void _showJobPreferencesEditDialog(BuildContext parentContext) {
//     final jp = widget.candidate.jobPreferences;
//     final industriesController = TextEditingController(text: jp.industries.join(', '));
//     final rolesController = TextEditingController(text: jp.roles.join(', '));
//     final salaryController = TextEditingController(text: jp.preferredSalary.toString());
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Job Preferences', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: industriesController,
//                 decoration: InputDecoration(
//                   labelText: 'Industries (comma-separated)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: rolesController,
//                 decoration: InputDecoration(
//                   labelText: 'Roles (comma-separated)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: salaryController,
//                 decoration: InputDecoration(
//                   labelText: 'Preferred Salary',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final updatedPrefs = JobPreferences(
//                 industries: industriesController.text.split(',').map((e) => e.trim()).toList(),
//                 roles: rolesController.text.split(',').map((e) => e.trim()).toList(),
//                 preferredSalary: int.tryParse(salaryController.text) ?? 0,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateJobPreferences(updatedPrefs));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSkillsEditDialog(BuildContext parentContext) {
//     final TextEditingController skillController = TextEditingController();
//     List<String> tempSkills = List.from(widget.candidate.skills);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (dialogContext, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text('Edit Skills', style: Theme.of(dialogContext).textTheme.displaySmall),
//           content: SizedBox(
//             width: screenSize.width * 0.85,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: skillController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter a skill (e.g., Flutter, Java)',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       filled: true,
//                       fillColor: AppColors.lightSurface,
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.add, color: AppColors.lightPrimary),
//                         onPressed: () {
//                           final skill = skillController.text.trim();
//                           if (skill.isNotEmpty && !tempSkills.contains(skill)) {
//                             setState(() {
//                               tempSkills.add(skill);
//                               skillController.clear();
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenSize.height * 0.015),
//                   if (tempSkills.isNotEmpty) ...[
//                     Text(
//                       'Your Skills',
//                       style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.lightText,
//                       ),
//                     ),
//                     SizedBox(height: screenSize.height * 0.01),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: tempSkills.map((skill) => Chip(
//                         label: Text(
//                           skill,
//                           style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
//                             color: AppColors.lightPrimary,
//                           ),
//                         ),
//                         backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
//                         deleteIcon: Icon(Icons.close, size: 18, color: AppColors.lightPrimary),
//                         onDeleted: () {
//                           setState(() => tempSkills.remove(skill));
//                         },
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                       )).toList(),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateSkills(tempSkills));
//                 Navigator.pop(dialogContext);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightPrimary,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: Text('Save', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showAddEducationDialog(BuildContext parentContext) {
//     final degreeController = TextEditingController();
//     final courseController = TextEditingController();
//     final institutionController = TextEditingController();
//     final startYearController = TextEditingController();
//     final passingYearController = TextEditingController();
//     final cgpaController = TextEditingController();
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Add Education', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: degreeController,
//                 decoration: InputDecoration(
//                   labelText: 'Degree',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: courseController,
//                 decoration: InputDecoration(
//                   labelText: 'Course',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: institutionController,
//                 decoration: InputDecoration(
//                   labelText: 'Institution',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: startYearController,
//                 decoration: InputDecoration(
//                   labelText: 'Start Year',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: passingYearController,
//                 decoration: InputDecoration(
//                   labelText: 'Passing Year',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: cgpaController,
//                 decoration: InputDecoration(
//                   labelText: 'CGPA (optional)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final newEducation = Education(
//                 id: DateTime.now().toString(), // Temporary ID, replace with server-generated ID
//                 degree: degreeController.text,
//                 course: courseController.text,
//                 institution: institutionController.text,
//                 startingYear: startYearController.text,
//                 passingYear: int.parse(passingYearController.text),
//                 cgpa: cgpaController.text,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddEducation(newEducation));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Add', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showEditEducationDialog(BuildContext parentContext, Education education) {
//     final degreeController = TextEditingController(text: education.degree);
//     final courseController = TextEditingController(text: education.course);
//     final institutionController = TextEditingController(text: education.institution);
//     final startYearController = TextEditingController(text: education.startingYear);
//     final passingYearController = TextEditingController(text: education.passingYear.toString());
//     final cgpaController = TextEditingController(text: education.cgpa);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Education', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: degreeController,
//                 decoration: InputDecoration(
//                   labelText: 'Degree',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: courseController,
//                 decoration: InputDecoration(
//                   labelText: 'Course',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: institutionController,
//                 decoration: InputDecoration(
//                   labelText: 'Institution',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: startYearController,
//                 decoration: InputDecoration(
//                   labelText: 'Start Year',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: passingYearController,
//                 decoration: InputDecoration(
//                   labelText: 'Passing Year',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: cgpaController,
//                 decoration: InputDecoration(
//                   labelText: 'CGPA (optional)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final updatedEducation = Education(
//                 id: education.id,
//                 degree: degreeController.text,
//                 course: courseController.text,
//                 institution: institutionController.text,
//                 startingYear: startYearController.text,
//                 passingYear: int.parse(passingYearController.text),
//                 cgpa: cgpaController.text,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateEducation(updatedEducation));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAddWorkExperienceDialog(BuildContext parentContext) {
//     final positionController = TextEditingController();
//     final companyController = TextEditingController();
//     final startDateController = TextEditingController();
//     final endDateController = TextEditingController();
//     bool isCurrentlyWorking = false;
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (dialogContext, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text('Add Work Experience', style: Theme.of(dialogContext).textTheme.displaySmall),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: positionController,
//                   decoration: InputDecoration(
//                     labelText: 'Position',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: companyController,
//                   decoration: InputDecoration(
//                     labelText: 'Company',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: startDateController,
//                   decoration: InputDecoration(
//                     labelText: 'Start Date (e.g., Jan 2020)',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 if (!isCurrentlyWorking)
//                   TextField(
//                     controller: endDateController,
//                     decoration: InputDecoration(
//                       labelText: 'End Date (e.g., Dec 2021)',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       filled: true,
//                       fillColor: AppColors.lightSurface,
//                     ),
//                   ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 CheckboxListTile(
//                   title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
//                   value: isCurrentlyWorking,
//                   onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
//                   activeColor: AppColors.lightPrimary,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final newExperience = WorkExperience(
//                   id: DateTime.now().toString(), // Temporary ID
//                   position: positionController.text,
//                   company: companyController.text,
//                   startDate: startDateController.text,
//                   endDate: isCurrentlyWorking ? '' : endDateController.text,
//                   isCurrentlyWorking: isCurrentlyWorking,
//                 );
//                 BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddWorkExperience(newExperience));
//                 Navigator.pop(dialogContext);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightPrimary,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: Text('Add', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showEditWorkExperienceDialog(BuildContext parentContext, WorkExperience experience) {
//     final positionController = TextEditingController(text: experience.position);
//     final companyController = TextEditingController(text: experience.company);
//     final startDateController = TextEditingController(text: experience.startDate);
//     final endDateController = TextEditingController(text: experience.endDate);
//     bool isCurrentlyWorking = experience.isCurrentlyWorking;
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (dialogContext, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text('Edit Work Experience', style: Theme.of(dialogContext).textTheme.displaySmall),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: positionController,
//                   decoration: InputDecoration(
//                     labelText: 'Position',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: companyController,
//                   decoration: InputDecoration(
//                     labelText: 'Company',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: startDateController,
//                   decoration: InputDecoration(
//                     labelText: 'Start Date (e.g., Jan 2020)',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 if (!isCurrentlyWorking)
//                   TextField(
//                     controller: endDateController,
//                     decoration: InputDecoration(
//                       labelText: 'End Date (e.g., Dec 2021)',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       filled: true,
//                       fillColor: AppColors.lightSurface,
//                     ),
//                   ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 CheckboxListTile(
//                   title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
//                   value: isCurrentlyWorking,
//                   onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
//                   activeColor: AppColors.lightPrimary,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final updatedExperience = WorkExperience(
//                   id: experience.id,
//                   position: positionController.text,
//                   company: companyController.text,
//                   startDate: startDateController.text,
//                   endDate: isCurrentlyWorking ? '' : endDateController.text,
//                   isCurrentlyWorking: isCurrentlyWorking,
//                 );
//                 BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateWorkExperience(updatedExperience));
//                 Navigator.pop(dialogContext);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightPrimary,
//
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: Text('Save', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showAddInternshipDialog(BuildContext parentContext) {
//     final projectNameController = TextEditingController();
//     final companyController = TextEditingController();
//     final startDateController = TextEditingController();
//     final endDateController = TextEditingController();
//     bool isCurrentlyWorking = false;
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (dialogContext, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text('Add Internship', style: Theme.of(dialogContext).textTheme.displaySmall),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: projectNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Project Name',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: companyController,
//                   decoration: InputDecoration(
//                     labelText: 'Company',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: startDateController,
//                   decoration: InputDecoration(
//                     labelText: 'Start Date (e.g., Jan 2020)',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 if (!isCurrentlyWorking)
//                   TextField(
//                     controller: endDateController,
//                     decoration: InputDecoration(
//                       labelText: 'End Date (e.g., Dec 2021)',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       filled: true,
//                       fillColor: AppColors.lightSurface,
//                     ),
//                   ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 CheckboxListTile(
//                   title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
//                   value: isCurrentlyWorking,
//                   onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
//                   activeColor: AppColors.lightPrimary,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final newInternship = Internship(
//                   id: DateTime.now().toString(), // Temporary ID
//                   projectName: projectNameController.text,
//                   company: companyController.text,
//                   startDate: startDateController.text,
//                   endDate: isCurrentlyWorking ? '' : endDateController.text,
//                   isCurrentlyWorking: isCurrentlyWorking,
//                 );
//                 BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddInternship(newInternship));
//                 Navigator.pop(dialogContext);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightPrimary,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: Text('Add', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showEditInternshipDialog(BuildContext parentContext, Internship internship) {
//     final projectNameController = TextEditingController(text: internship.projectName);
//     final companyController = TextEditingController(text: internship.company);
//     final startDateController = TextEditingController(text: internship.startDate);
//     final endDateController = TextEditingController(text: internship.endDate);
//     bool isCurrentlyWorking = internship.isCurrentlyWorking;
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (dialogContext, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text('Edit Internship', style: Theme.of(dialogContext).textTheme.displaySmall),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: projectNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Project Name',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: companyController,
//                   decoration: InputDecoration(
//                     labelText: 'Company',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 TextField(
//                   controller: startDateController,
//                   decoration: InputDecoration(
//                     labelText: 'Start Date (e.g., Jan 2020)',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     filled: true,
//                     fillColor: AppColors.lightSurface,
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 if (!isCurrentlyWorking)
//                   TextField(
//                     controller: endDateController,
//                     decoration: InputDecoration(
//                       labelText: 'End Date (e.g., Dec 2021)',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       filled: true,
//                       fillColor: AppColors.lightSurface,
//                     ),
//                   ),
//                 SizedBox(height: screenSize.height * 0.015),
//                 CheckboxListTile(
//                   title: Text('Currently Working', style: Theme.of(dialogContext).textTheme.bodyMedium),
//                   value: isCurrentlyWorking,
//                   onChanged: (value) => setState(() => isCurrentlyWorking = value ?? false),
//                   activeColor: AppColors.lightPrimary,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final updatedInternship = Internship(
//                   id: internship.id,
//                   projectName: projectNameController.text,
//                   company: companyController.text,
//                   startDate: startDateController.text,
//                   endDate: isCurrentlyWorking ? '' : endDateController.text,
//                   isCurrentlyWorking: isCurrentlyWorking,
//                 );
//                 BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateInternship(updatedInternship));
//                 Navigator.pop(dialogContext);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightPrimary,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: Text('Save', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showAddProjectDialog(BuildContext parentContext) {
//     final projectNameController = TextEditingController();
//     final startDateController = TextEditingController();
//     final endDateController = TextEditingController();
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Add Project', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: projectNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Project Name',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: startDateController,
//                 decoration: InputDecoration(
//                   labelText: 'Start Date (e.g., Jan 2020)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: endDateController,
//                 decoration: InputDecoration(
//                   labelText: 'End Date (e.g., Dec 2021)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final newProject = Project(
//                 id: DateTime.now().toString(), // Temporary ID
//                 projectName: projectNameController.text,
//                 startDate: startDateController.text,
//                 endDate: endDateController.text,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddProject(newProject));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Add', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//   void _showEditProjectDialog(BuildContext parentContext, Project project) {
//     final projectNameController = TextEditingController(text: project.projectName);
//     final startDateController = TextEditingController(text: project.startDate);
//     final endDateController = TextEditingController(text: project.endDate);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Project', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: projectNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Project Name',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: startDateController,
//                 decoration: InputDecoration(
//                   labelText: 'Start Date (e.g., Jan 2020)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: endDateController,
//                 decoration: InputDecoration(
//                   labelText: 'End Date (e.g., Dec 2021)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final updatedProject = Project(
//                 id: project.id,
//                 projectName: projectNameController.text,
//                 startDate: startDateController.text,
//                 endDate: endDateController.text,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateProject(updatedProject));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//   void _showAddCertificationDialog(BuildContext parentContext) {
//     final nameController = TextEditingController();
//     final orgController = TextEditingController();
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Add Certification', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Certification Name',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: orgController,
//                 decoration: InputDecoration(
//                   labelText: 'Issuing Organization',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final newCertification = Certification(
//                 id: DateTime.now().toString(), // Temporary ID
//                 name: nameController.text,
//                 issuingOrganization: orgController.text,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(AddCertification(newCertification));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Add', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//   void _showEditCertificationDialog(BuildContext parentContext, Certification certification) {
//     final nameController = TextEditingController(text: certification.name);
//     final orgController = TextEditingController(text: certification.issuingOrganization);
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Edit Certification', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Certification Name',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.015),
//               TextField(
//                 controller: orgController,
//                 decoration: InputDecoration(
//                   labelText: 'Issuing Organization',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.lightSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final updatedCertification = Certification(
//                 id: certification.id,
//                 name: nameController.text,
//                 issuingOrganization: orgController.text,
//               );
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateCertification(updatedCertification));
//               Navigator.pop(dialogContext);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightPrimary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//   void _uploadResume(BuildContext parentContext) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
//     if (result != null) {
//       File file = File(result.files.single.path!);
//      // BlocProvider.of<CandidateProfileBloc>(parentContext).add(UpdateResume(file.path));
//     }
//   }
//
//   void _confirmDelete(BuildContext parentContext, String type, String id, String itemName) {
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Confirm Delete', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: Text('Are you sure you want to delete "$itemName"?', style: Theme.of(dialogContext).textTheme.bodyMedium),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightError,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             onPressed: () {
//               switch (type) {
//                 case 'education':
//                   BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteEducation(id));
//                   break;
//                 case 'work-experience':
//                   BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteWorkExperience(id));
//                   break;
//                 case 'internship':
//                   BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteInternship(id));
//                   break;
//                 case 'project':
//                   BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteProject(id));
//                   break;
//                 case 'certification':
//                   BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteCertification(id));
//                   break;
//               }
//               Navigator.pop(dialogContext);
//             },
//             child: Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//   void _confirmDeleteResume(BuildContext parentContext) {
//     final screenSize = MediaQuery.of(parentContext).size;
//
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Confirm Delete', style: Theme.of(dialogContext).textTheme.displaySmall),
//         content: Text('Are you sure you want to delete your resume?', style: Theme.of(dialogContext).textTheme.bodyMedium),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: Theme.of(dialogContext).textTheme.bodyMedium),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.lightError,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             onPressed: () {
//               BlocProvider.of<CandidateProfileBloc>(parentContext).add(DeleteResume());
//               Navigator.pop(dialogContext);
//             },
//             child: Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }