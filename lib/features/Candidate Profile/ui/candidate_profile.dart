import 'dart:ui';

import 'package:android/core/utils/snackBarUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Not provided';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<DateTime?> _pickDate(BuildContext context,
      {DateTime? initialDate}) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CandidateProfileBloc>(context).add(FetchProfileData());
  }

  Future<void> _updateProfilePicture(
      BuildContext context, String previousPublicId) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.lightPrimary
                    : AppColors.lightPrimary,
                size: 30),
          );
        },
      );
      try {
        File imageFile = File(image.path);
        Map<String, dynamic> personalInfo = {
          'profilePic': imageFile,
          'publicId': previousPublicId
        };

        BlocProvider.of<CandidateProfileBloc>(context)
            .add(UpdatePersonalProfile(personalInfo));
        Navigator.pop(context);
      } catch (e) {
        SnackBarUtils.showRedSnackBar(
            "Failed to Update Employer Profile picture", context);
      }
    }
  }

  Map<String, Map<String, String>> documentUrl = {
    'disabledCertificate': {'url': '', 'publicId': ''},
  };
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return BlocConsumer<CandidateProfileBloc, CandidateProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          SnackBarUtils.showGreenSnackBar(state.message, context);
        }
        if (state is ProfileError) {
          SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
      },
      builder: (context, state) {
        if (state is ProfileDataLoading) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.lightPrimary
                    : AppColors.lightPrimary,
                size: 30),
          );
        } else if (state is ProfileDataLoaded) {
          return _buildLoadedState(context, state, screenSize);
        }
        // } else if (state is ProfileError) {
        //   return CustomErrorScreen(message: state.error,onRetry: (){
        //     BlocProvider.of<CandidateProfileBloc>(context).add(FetchProfileData());
        //   },);
        // }
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

  Widget _buildLoadedState(
      BuildContext context, ProfileDataLoaded state, Size screenSize) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(state.candidate, screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildInfoCards(context, state, screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Candidate candidate, Size screenSize) {
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
              top: 60,
              bottom: 10,
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
                                backgroundImage: candidate
                                            .personalInfo.profilePic !=
                                        null
                                    ? NetworkImage(
                                        candidate.personalInfo.profilePic!)
                                    : AssetImage('assets/default_profile.png')
                                        as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _updateProfilePicture(
                                context, candidate.personalInfo.publicId),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
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
                  SizedBox(height: screenSize.height * 0.02),
                  Text(candidate.personalInfo.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: screenSize.width * 0.06,
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
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(
      BuildContext context, ProfileDataLoaded state, Size screenSize) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildProfileSummarySection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildAboutSection(state.candidate, screenSize),
          SizedBox(height: screenSize.height * 0.02),
          _buildDisabilityDetailsSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildJobPreferencesSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildSkillsSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildEducationSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildWorkExperienceSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildInternshipSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildProjectsSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
          _buildCertificationsSection(state.candidate),
          SizedBox(height: screenSize.height * 0.02),
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
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        IconButton(
          icon: Icon(Icons.add_circle, color: Colors.blue.shade600),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(Candidate candidate) {
    final screenSize = MediaQuery.of(context).size;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.personalInfo.fullName,
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
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
                    Text(
                      candidate.personalInfo.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightSecondaryText,
                          ),
                    ),
                    Text(
                      'DOB: ${formatDate(candidate.personalInfo.dob.toString())}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightSecondaryText,
                          ),
                    ),
                    Text(
                      'Gender: ${candidate.personalInfo.gender}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightSecondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon:
                    Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                onPressed: () =>
                    _showPersonalInfoEditDialog(context, candidate),
              ),
            ],
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
              Text('Profile Summary',
                  style: Theme.of(context).textTheme.displaySmall),
              IconButton(
                icon:
                    Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                onPressed: () =>
                    _showProfileSummaryEditDialog(context, candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          Text(
            candidate.profileSummary.isNotEmpty
                ? candidate.profileSummary
                : 'No profile summary added yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: candidate.profileSummary.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: candidate.profileSummary.isEmpty
                      ? AppColors.lightSecondaryText
                      : null,
                ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Candidate candidate, Size screenSize) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('About', style: Theme.of(context).textTheme.displaySmall),
              IconButton(
                icon:
                    Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                onPressed: () => _showAboutEditDialog(context, candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          Text(
            candidate.about.isNotEmpty
                ? candidate.about
                : 'Tell employers about yourself.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: candidate.profileSummary.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: candidate.profileSummary.isEmpty
                      ? AppColors.lightSecondaryText
                      : null,
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
                style: Theme.of(context).textTheme.displaySmall?.copyWith(),
              ),
              IconButton(
                icon:
                    Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                onPressed: () =>
                    _showDisabilityDetailsEditDialog(context, candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          if (hasDisabilityInfo) ...[
            _buildInfoRow('Type', candidate.disabilityDetails.type),
            _buildInfoRow(
                'Percentage', '${candidate.disabilityDetails.percentage}%'),
            _buildInfoRow('Certificate No.',
                candidate.disabilityDetails.certificateNumber),
            if (candidate.disabilityDetails.accommodationsNeeded.isNotEmpty)
              _buildInfoRow('Accommodations',
                  candidate.disabilityDetails.accommodationsNeeded.join(', ')),
            if (candidate.disabilityDetails.assistiveTechnology.isNotEmpty)
              _buildInfoRow('Assistive Tech',
                  candidate.disabilityDetails.assistiveTechnology.join(', ')),
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
    final hasJobPreferences = jp.industries.isNotEmpty ||
        jp.roles.isNotEmpty ||
        jp.preferredSalary > 0 ||
        jp.location.isNotEmpty ||
        jp.workMode.isNotEmpty ||
        jp.employmentType.isNotEmpty ||
        jp.experienceLevel.isNotEmpty;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Job Preferences',
                  style: Theme.of(context).textTheme.displaySmall),
              IconButton(
                icon:
                    Icon(FontAwesomeIcons.edit, color: AppColors.lightPrimary),
                onPressed: () =>
                    _showJobPreferencesEditDialog(context, candidate),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.015),
          if (hasJobPreferences) ...[
            if (jp.industries.isNotEmpty)
              _buildInfoRow('Industries', jp.industries.join(', ')),
            if (jp.roles.isNotEmpty)
              _buildInfoRow('Roles', jp.roles.join(', ')),
            if (jp.preferredSalary > 0)
              _buildInfoRow('Salary', '\₹${jp.preferredSalary}'),
            if (jp.location.isNotEmpty)
              _buildInfoRow('Locations', jp.location.join(', ')),
            if (jp.workMode.isNotEmpty) _buildInfoRow('Work Mode', jp.workMode),
            if (jp.employmentType.isNotEmpty)
              _buildInfoRow('Employment Type', jp.employmentType.join(', ')),
            if (jp.experienceLevel.isNotEmpty)
              _buildInfoRow('Experience Level', jp.experienceLevel),
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
            () => _showSkillsEditDialog(context, candidate),
          ),
          SizedBox(height: screenSize.height * 0.015),
          if (candidate.skills.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 64),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: candidate.skills
                    .map((skill) => Chip(
                          label: Text(
                            skill,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.lightPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          backgroundColor:
                              AppColors.lightPrimary.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: AppColors.lightPrimary.withOpacity(0.2)),
                          ),
                          elevation: 1,
                          shadowColor: AppColors.lightText.withOpacity(0.1),
                        ))
                    .toList(),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'Education', () => _showAddEducationDialog(context, candidate)),
          SizedBox(height: screenSize.height * 0.01),
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
              separatorBuilder: (context, index) =>
                  Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final edu = candidate.education[index];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                  title: Text(edu.course),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edu.institution),
                      if (edu.specialization.isNotEmpty)
                        Text('Specialization: ${edu.specialization}'),
                      Text(
                          '${edu.startingYear.toString().split(" ")[0]} - ${edu.passingYear.toString().split(" ")[0]}'),
                      if (edu.CGPA.isNotEmpty) Text('CGPA: ${edu.CGPA}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit,
                            color: AppColors.lightPrimary),
                        onPressed: () =>
                            _showEditEducationDialog(context, edu, candidate),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          print("EduId ${edu.id}");
                          _confirmDelete(context, 'education', edu.id,
                              '${edu.course} from ${edu.institution}');
                        },
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
          _buildSectionHeader(
              'Work Experience', () => _showAddWorkExperienceDialog(context)),
          SizedBox(height: screenSize.height * 0.01),
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
              separatorBuilder: (context, index) =>
                  Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final exp = candidate.workExperience[index];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
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
                      Text(exp.company,
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        '${formatDate(exp.startDate.toString())} - ${exp.endDate == null ? 'Present' : formatDate(exp.endDate.toString())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (exp.descriptions.isNotEmpty)
                        Text(
                          exp.descriptions,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit,
                            color: AppColors.lightPrimary),
                        onPressed: () =>
                            _showEditWorkExperienceDialog(context, exp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            context,
                            'work-experience',
                            exp.id,
                            '${exp.position} at ${exp.company}'),
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
          _buildSectionHeader(
              'Internships', () => _showAddInternshipDialog(context)),
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
              separatorBuilder: (context, index) =>
                  Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final internship = candidate.internships[index];
                return ListTile(
                  title: Text(internship.projectName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(internship.company),
                      Text(
                          '${formatDate(internship.startDate.toString())} - ${internship.endDate == null ? 'Present' : formatDate(internship.endDate.toString())}'),
                      if (internship.role.isNotEmpty)
                        Text('Role: ${internship.role}'),
                      if (internship.descriptions.isNotEmpty)
                        Text(internship.descriptions),
                      if (internship.skills.isNotEmpty)
                        Text('Skills: ${internship.skills.join(', ')}'),
                      if (internship.projectUrl.isNotEmpty)
                        Text('URL: ${internship.projectUrl}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit,
                            color: AppColors.lightPrimary),
                        onPressed: () =>
                            _showEditInternshipDialog(context, internship),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            context,
                            'internship',
                            internship.id,
                            '${internship.projectName} at ${internship.company}'),
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
          SizedBox(height: screenSize.height * 0.01),
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
              separatorBuilder: (context, index) =>
                  Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final project = candidate.projects[index];
                return ListTile(
                  title: Text(project.projectName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${formatDate(project.startDate.toString())} - ${project.endDate == null ? 'Present' : formatDate(project.endDate.toString())}'),
                      if (project.descriptions.isNotEmpty)
                        Text(project.descriptions),
                      if (project.skills.isNotEmpty)
                        Text('Skills: ${project.skills.join(', ')}'),
                      if (project.projectUrl.isNotEmpty)
                        Text('URL: ${project.projectUrl}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit,
                            color: AppColors.lightPrimary),
                        onPressed: () =>
                            _showEditProjectDialog(context, project),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, 'project',
                            project.id, project.projectName),
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
          _buildSectionHeader(
              'Certifications', () => _showAddCertificationDialog(context)),
          SizedBox(height: screenSize.height * 0.01),
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
              separatorBuilder: (context, index) =>
                  Divider(color: AppColors.lightDivider),
              itemBuilder: (context, index) {
                final cert = candidate.certifications[index];
                return ListTile(
                  title: Text(cert.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.issuingOrganization),
                      if (cert.issueDate != null)
                        Text(formatDate(cert.issueDate.toString())),
                      if (cert.credentialID.isNotEmpty)
                        Text('ID: ${cert.credentialID}'),
                      if (cert.url.isNotEmpty) Text('URL: ${cert.url}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FontAwesomeIcons.edit,
                            color: AppColors.lightPrimary),
                        onPressed: () =>
                            _showEditCertificationDialog(context, cert),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            context, 'certification', cert.id, cert.name),
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
    Map<String, String> resumeUrl = {
      'url': candidate.resume.url,
      'publicId': candidate.resume.publicId,
    };

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
          StatefulBuilder(
            builder: (context, setState) =>
                BlocListener<CandidateProfileBloc, CandidateProfileState>(
              listener: (context, state) {
                if (state is ProfileUpdateSuccess) {
                  print("State $state");
                  SnackBarUtils.showGreenSnackBar(
                      'Resume uploaded successfully', context);
                } else if (state is ProfileError) {
                  SnackBarUtils.showRedSnackBar(state.error, context);
                }
              },
              child: _buildResumeUploadCard(
                context,
                'Resume',
                'Upload your resume (PDF, DOC, JPG, PNG)',
                'resume',
                Icons.description,
                screenSize,
                resumeUrl,
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
        borderRadius:
            Theme.of(context).cardTheme.shape is RoundedRectangleBorder
                ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder)
                    .borderRadius
                : BorderRadius.circular(16),
        boxShadow: [
          Theme.of(context).cardTheme.shadowColor != null
              ? BoxShadow(
                  color: Theme.of(context).cardTheme.shadowColor!,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              : const BoxShadow()
        ],
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfoEditDialog(
      BuildContext parentContext, Candidate candidate) {
    final nameController =
        TextEditingController(text: candidate.personalInfo.fullName);
    final emailController =
        TextEditingController(text: candidate.personalInfo.email);
    final phoneController =
        TextEditingController(text: candidate.personalInfo.phoneNumber);
    final addressController =
        TextEditingController(text: candidate.personalInfo.address);

    DateTime? dobController = candidate.personalInfo.dob;

    final genderController =
        TextEditingController(text: candidate.personalInfo.gender);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Personal Information',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Full Name', Icons.person),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(emailController, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(phoneController, 'Phone Number', Icons.phone,
                  keyboardType: TextInputType.phone),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(addressController, 'Address', Icons.location_on),
              SizedBox(height: screenSize.height * 0.015),
              SizedBox(height: screenSize.height * 0.015),
              _buildDateField(
                  'DOB', dobController, (date) => dobController = date),
              SizedBox(height: screenSize.height * 0.015),
              DropdownButtonFormField<String>(
                value: genderController.text.isEmpty
                    ? 'Male'
                    : genderController.text,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.lightSurface,
                ),
                items: ['Male', 'Female', 'Other']
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  genderController.text = value ?? 'Male';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedInfo = {
                "fullName": nameController.text,
                "email": emailController.text,
                "phoneNumber": phoneController.text,
                "address": addressController.text,
                "DOB": dobController?.toString(),
                "gender": genderController.text,
              };
              BlocProvider.of<CandidateProfileBloc>(parentContext)
                  .add(UpdatePersonalProfile(updatedInfo));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileSummaryEditDialog(
      BuildContext parentContext, Candidate candidate) {
    final controller = TextEditingController(text: candidate.profileSummary);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profile Summary',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: _buildTextField(
            controller, 'Profile Summary', Icons.description,
            isMultiLine: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<CandidateProfileBloc>(parentContext)
                  .add(UpdateProfileSummary(controller.text));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutEditDialog(BuildContext parentContext, Candidate candidate) {
    final controller = TextEditingController(text: candidate.about);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit About',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: _buildTextField(
          controller,
          'About',
          Icons.person_outline,
          hintText: 'Tell employers about yourself...',
          isMultiLine: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<CandidateProfileBloc>(parentContext)
                  .add(UpdateAbout(controller.text));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDisabilityDetailsEditDialog(
      BuildContext parentContext, Candidate candidate) {
    final typeController =
        TextEditingController(text: candidate.disabilityDetails.type);
    final percentageController = TextEditingController(
        text: candidate.disabilityDetails.percentage.toString());
    final certController = TextEditingController(
        text: candidate.disabilityDetails.certificateNumber);
    final accommodationsController = TextEditingController(
        text: candidate.disabilityDetails.accommodationsNeeded.join(', '));
    final prefCommController = TextEditingController(
        text: candidate.disabilityDetails.preferredCommunicationMethod);
    final techController = TextEditingController(
        text: candidate.disabilityDetails.assistiveTechnology.join(', '));
    String certificateDocUrl = candidate.disabilityDetails.certificateDoc;
    String publicId = candidate.disabilityDetails.publicId;
    final screenSize = MediaQuery.of(parentContext).size;

    documentUrl['disabledCertificate'] = {
      'url': certificateDocUrl,
      'publicId': publicId
    };

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) =>
            BlocListener<CandidateProfileBloc, CandidateProfileState>(
          bloc: BlocProvider.of<CandidateProfileBloc>(
              parentContext), // Use parentContext to get the bloc
          listener: (context, state) {
            if (state is DocumentUploaded) {
              setState(() {
                certificateDocUrl = state.url;
                publicId = state.publicId;
                documentUrl['disabledCertificate'] = {
                  'url': state.url,
                  'publicId': state.publicId
                }; // Update documentUrl
                SnackBarUtils.showGreenSnackBar(
                    'Document uploaded successfully', dialogContext);
              });
              Navigator.pop(dialogContext); // Close the upload dialog
            } else if (state is ProfileError) {
              SnackBarUtils.showRedSnackBar(state.error, dialogContext);
              Navigator.pop(dialogContext); // Close the upload dialog on error
            }
          },
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Edit Disability Details',
                style: Theme.of(dialogContext).textTheme.displaySmall),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                      typeController, 'Disability Type', Icons.accessibility),
                  SizedBox(height: screenSize.height * 0.015),
                  _buildTextField(
                    percentageController,
                    'Percentage (%)',
                    Icons.percent,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  _buildTextField(certController, 'Certificate Number',
                      Icons.card_membership),
                  SizedBox(height: screenSize.height * 0.015),
                  _buildTextField(
                    accommodationsController,
                    'Accommodations Needed',
                    Icons.support,
                    hintText: 'Comma-separated',
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  _buildTextField(
                    prefCommController,
                    'Preferred Communication',
                    Icons.phone,
                    hintText: 'e.g., Email, Sign Language',
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  _buildTextField(
                    techController,
                    'Assistive Technology',
                    Icons.assist_walker,
                    hintText: 'Comma-separated',
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  _buildDocumentUploadCard(
                      parentContext, // Pass parentContext instead of dialogContext
                      'Disability Certificate',
                      'Upload your disability certificate (PDF, DOC, JPG, PNG)',
                      'disabledCertificate',
                      Icons.description,
                      screenSize,
                      setState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel',
                    style: Theme.of(dialogContext).textTheme.bodyMedium),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedDetails = DisabilityDetails(
                    type: typeController.text,
                    percentage: int.tryParse(percentageController.text) ?? 0,
                    certificateNumber: certController.text,
                    certificateDoc: certificateDocUrl,
                    publicId: publicId,
                    accommodationsNeeded: accommodationsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(),
                    preferredCommunicationMethod: prefCommController.text,
                    assistiveTechnology: techController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(),
                  );
                  print(updatedDetails);
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(UpdateDisabilityDetails(updatedDetails));
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobPreferencesEditDialog(
      BuildContext parentContext, Candidate candidate) {
    final jp = candidate.jobPreferences;
    final industriesController =
        TextEditingController(text: jp.industries.join(', '));
    final rolesController = TextEditingController(text: jp.roles.join(', '));
    final salaryController =
        TextEditingController(text: jp.preferredSalary.toString());
    final locationController =
        TextEditingController(text: jp.location.join(', '));
    final workModeController = TextEditingController(text: jp.workMode);
    final employmentTypeController =
        TextEditingController(text: jp.employmentType.join(', '));
    final experienceLevelController =
        TextEditingController(text: jp.experienceLevel);

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Job Preferences',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                industriesController,
                'Industries',
                Icons.business,
                hintText: 'Comma-separated',
              ),
              SizedBox(height: 8),
              _buildTextField(
                rolesController,
                'Roles',
                Icons.work,
                hintText: 'Comma-separated',
              ),
              SizedBox(height: 8),
              _buildTextField(
                salaryController,
                'Preferred Salary',
                Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              _buildTextField(
                locationController,
                'Locations',
                Icons.location_on,
                hintText: 'Comma-separated',
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: workModeController.text.isEmpty
                    ? 'Flexible'
                    : workModeController.text,
                decoration: InputDecoration(
                  labelText: 'Work Mode',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                items: ['Remote', 'Onsite', 'Hybrid', 'Flexible']
                    .map((mode) =>
                        DropdownMenuItem(value: mode, child: Text(mode)))
                    .toList(),
                onChanged: (value) =>
                    workModeController.text = value ?? 'Flexible',
              ),
              SizedBox(height: 8),
              _buildTextField(
                employmentTypeController,
                'Employment Type',
                Icons.schedule,
                hintText: 'Comma-separated (Full-time, Part-time, etc.)',
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: experienceLevelController.text.isEmpty
                    ? 'Freshers'
                    : experienceLevelController.text,
                decoration: InputDecoration(
                  labelText: 'Experience Level',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.star),
                ),
                items: ['Freshers', 'Intermediate', 'Professional']
                    .map((level) =>
                        DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) =>
                    experienceLevelController.text = value ?? 'Freshers',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedPrefs = JobPreferences(
                industries: industriesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                roles: rolesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                preferredSalary: int.tryParse(salaryController.text) ?? 0,
                location: locationController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                workMode: workModeController.text,
                employmentType: employmentTypeController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                experienceLevel: experienceLevelController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext)
                  .add(UpdateJobPreferences(updatedPrefs));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSkillsEditDialog(BuildContext parentContext, Candidate candidate) {
    final TextEditingController skillController = TextEditingController();
    List<String> tempSkills = List.from(candidate.skills);
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Skills',
              style: Theme.of(dialogContext).textTheme.displaySmall),
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                      style:
                          Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightText,
                              ),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempSkills
                          .map((skill) => Chip(
                                label: Text(
                                  skill,
                                  style: Theme.of(dialogContext)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.lightPrimary,
                                      ),
                                ),
                                backgroundColor:
                                    AppColors.lightPrimary.withOpacity(0.1),
                                deleteIcon: Icon(Icons.close,
                                    size: 18, color: AppColors.lightPrimary),
                                onDeleted: () {
                                  setState(() => tempSkills.remove(skill));
                                },
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(UpdateSkills(tempSkills));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEducationDialog(
      BuildContext parentContext, Candidate candidate) {
    final courseController = TextEditingController();
    final specializationController = TextEditingController();
    final institutionController = TextEditingController();
    final cgpaController = TextEditingController();
    DateTime? startDate;
    DateTime? passingDate;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Education',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(courseController, 'Course', Icons.school),
              SizedBox(height: 8),
              _buildTextField(
                  specializationController, 'Specialization', Icons.book),
              SizedBox(height: 8),
              _buildTextField(
                  institutionController, 'Institution', Icons.account_balance),
              SizedBox(height: 8),
              _buildDateField(
                  'Start Date', startDate, (date) => startDate = date),
              SizedBox(height: 8),
              _buildDateField(
                  'Passing Date', passingDate, (date) => passingDate = date),
              SizedBox(height: 8),
              _buildTextField(cgpaController, 'CGPA', Icons.grade,
                  hintText: 'Optional'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              if (startDate != null && passingDate != null) {
                final newEducation = Education(
                  id: DateTime.now().toString(),
                  course: courseController.text,
                  specialization: specializationController.text,
                  institution: institutionController.text,
                  startingYear: startDate,
                  passingYear: passingDate,
                  CGPA: cgpaController.text,
                );

                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(AddEducation(newEducation));
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditEducationDialog(
      BuildContext parentContext, Education education, Candidate candidate) {
    final courseController = TextEditingController(text: education.course);
    final specializationController =
        TextEditingController(text: education.specialization);
    final institutionController =
        TextEditingController(text: education.institution);
    final cgpaController = TextEditingController(text: education.CGPA);
    DateTime? startDate = education.startingYear;
    DateTime? passingDate = education.passingYear;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Education',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(courseController, 'Course', Icons.school),
              SizedBox(height: 8),
              _buildTextField(
                  specializationController, 'Specialization', Icons.book),
              SizedBox(height: 8),
              _buildTextField(
                  institutionController, 'Institution', Icons.account_balance),
              SizedBox(height: 8),
              _buildDateField(
                  'Start Date', startDate, (date) => startDate = date),
              SizedBox(height: 8),
              _buildDateField(
                  'Passing Date', passingDate, (date) => passingDate = date),
              SizedBox(height: 8),
              _buildTextField(cgpaController, 'CGPA', Icons.grade,
                  hintText: 'Optional'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              if (startDate != null && passingDate != null) {
                final updatedEducation = Education(
                  id: education.id,
                  course: courseController.text,
                  specialization: specializationController.text,
                  institution: institutionController.text,
                  startingYear: startDate,
                  passingYear: passingDate!,
                  CGPA: cgpaController.text,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(UpdateEducation(updatedEducation));
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
    final descriptionController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Work Experience',
              style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(positionController, 'Position', Icons.work),
                SizedBox(height: 8),
                _buildTextField(companyController, 'Company', Icons.business),
                SizedBox(height: 8),
                _buildTextField(
                    descriptionController, 'Descriptions', Icons.description,
                    hintText: 'Comma-separated'),
                SizedBox(height: 8),
                _buildDateField(
                    'Start Date', startDate, (date) => startDate = date),
                SizedBox(height: 8),
                _buildDateField(
                    'End Date (Optional)', endDate, (date) => endDate = date),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDate != null) {
                  final newExperience = WorkExperience(
                    id: DateTime.now().toString(),
                    position: positionController.text,
                    company: companyController.text,
                    startDate: startDate,
                    endDate: endDate,
                    descriptions: descriptionController.text,
                  );
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(AddWorkExperience(newExperience));
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWorkExperienceDialog(
      BuildContext parentContext, WorkExperience experience) {
    final positionController = TextEditingController(text: experience.position);
    final companyController = TextEditingController(text: experience.company);
    final descriptionController =
        TextEditingController(text: experience.descriptions);
    DateTime? startDate = experience.startDate;
    DateTime? endDate = experience.endDate;
    // final startDateController = TextEditingController(text: experience.startDate?.toIso8601String());
    // final endDateController = TextEditingController(text: experience.endDate?.toIso8601String());
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Work Experience',
              style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(positionController, 'Position', Icons.work),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(companyController, 'Company', Icons.business),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(
                    descriptionController, 'Descriptions', Icons.business),
                SizedBox(height: screenSize.height * 0.015),
                _buildDateField(
                    'Start Date', startDate, (date) => startDate = date),
                SizedBox(height: 8),
                _buildDateField(
                    'End Date (Optional)', endDate, (date) => endDate = date),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedExperience = WorkExperience(
                  id: experience.id,
                  position: positionController.text,
                  company: companyController.text,
                  descriptions: descriptionController.text,
                  startDate: startDate,
                  endDate: endDate,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(UpdateWorkExperience(updatedExperience));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
    final roleController = TextEditingController();
    final descriptionController = TextEditingController();
    final skillsController = TextEditingController();
    final urlController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    Size screenSize = MediaQuery.of(context).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Internship',
              style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                    projectNameController, 'Project Name', Icons.folder),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(companyController, 'Company', Icons.business),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(roleController, 'Role', Icons.person),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(
                    descriptionController, 'Description', Icons.description),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(skillsController, 'Skills', Icons.star,
                    hintText: 'Comma-separated'),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(urlController, 'Project URL', Icons.link,
                    hintText: 'Optional'),
                SizedBox(height: screenSize.height * 0.015),
                _buildDateField(
                    'Start Date', startDate, (date) => startDate = date),
                SizedBox(height: screenSize.height * 0.015),
                _buildDateField(
                    'End Date (Optional)', endDate, (date) => endDate = date),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDate != null) {
                  final newInternship = Internship(
                    projectName: projectNameController.text,
                    company: companyController.text,
                    role: roleController.text,
                    startDate: startDate,
                    endDate: endDate,
                    descriptions: descriptionController.text,
                    skills: skillsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(),
                    projectUrl: urlController.text,
                  );
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(AddInternship(newInternship));
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditInternshipDialog(
      BuildContext parentContext, Internship internship) {
    final projectNameController =
        TextEditingController(text: internship.projectName);
    final companyController = TextEditingController(text: internship.company);
    final roleController = TextEditingController(text: internship.role);
    final descriptionController =
        TextEditingController(text: internship.descriptions);
    final skillsController =
        TextEditingController(text: internship.skills.join(","));
    final projectUrlController =
        TextEditingController(text: internship.projectUrl);
    DateTime? startDate = internship.startDate;
    DateTime? endDate = internship.endDate;

    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Internship',
              style: Theme.of(dialogContext).textTheme.displaySmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                    projectNameController, 'Project Name', Icons.folder),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(companyController, 'Company', Icons.business),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(roleController, 'Role', Icons.person),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(
                    descriptionController, 'Description', Icons.description),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(skillsController, 'Skills', Icons.star,
                    hintText: 'Comma-separated'),
                SizedBox(height: screenSize.height * 0.015),
                _buildTextField(projectUrlController, 'Project URL', Icons.link,
                    hintText: 'Optional'),
                SizedBox(height: screenSize.height * 0.015),
                _buildDateField(
                    'Start Date', startDate, (date) => startDate = date),
                SizedBox(height: screenSize.height * 0.015),
                _buildDateField(
                    'End Date (Optional)', endDate, (date) => endDate = date),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: Theme.of(dialogContext).textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedInternship = Internship(
                  id: internship.id,
                  projectName: projectNameController.text,
                  company: companyController.text,
                  role: roleController.text,
                  startDate: startDate,
                  endDate: endDate,
                  descriptions: descriptionController.text,
                  skills: skillsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  projectUrl: projectUrlController.text,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(UpdateInternship(updatedInternship));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
    final descriptionController = TextEditingController();
    final skillsController = TextEditingController();
    final urlController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Project',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  projectNameController, 'Project Name', Icons.folder),
              SizedBox(height: 8),
              _buildTextField(
                  descriptionController, 'Description', Icons.description),
              SizedBox(height: 8),
              _buildTextField(skillsController, 'Skills', Icons.star,
                  hintText: 'Comma-separated'),
              SizedBox(height: 8),
              _buildTextField(urlController, 'Project URL', Icons.link,
                  hintText: 'Optional'),
              SizedBox(height: 8),
              _buildDateField(
                  'Start Date', startDate, (date) => startDate = date),
              SizedBox(height: 8),
              _buildDateField(
                  'End Date (Optional)', endDate, (date) => endDate = date),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              if (startDate != null) {
                final newProject = Project(
                  projectName: projectNameController.text,
                  startDate: startDate,
                  endDate: endDate,
                  descriptions: descriptionController.text,
                  skills: skillsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  projectUrl: urlController.text,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(AddProject(newProject));
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext parentContext, Project project) {
    final projectNameController =
        TextEditingController(text: project.projectName);
    final descriptionController =
        TextEditingController(text: project.descriptions);
    final skillsController =
        TextEditingController(text: project.skills.join(","));
    final urlController = TextEditingController(text: project.projectUrl);
    DateTime? startDate = project.startDate;
    DateTime? endDate = project.endDate;

    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Project',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  projectNameController, 'Project Name', Icons.folder),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(
                  descriptionController, 'Description', Icons.description),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(skillsController, 'Skills', Icons.star,
                  hintText: 'Comma-separated'),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(urlController, 'Project URL', Icons.link,
                  hintText: 'Optional'),
              SizedBox(height: screenSize.height * 0.015),
              _buildDateField(
                  'Start Date', startDate, (date) => startDate = date),
              SizedBox(height: screenSize.height * 0.015),
              _buildDateField(
                  'End Date (Optional)', endDate, (date) => endDate = date),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProject = Project(
                id: project.id,
                projectName: projectNameController.text,
                startDate: startDate,
                endDate: endDate,
                descriptions: descriptionController.text,
                skills: skillsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                projectUrl: urlController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext)
                  .add(UpdateProject(updatedProject));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
    final credentialController = TextEditingController();
    final urlController = TextEditingController();
    DateTime? issueDate;
    Size screenSize = MediaQuery.of(context).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Certification',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  nameController, 'Certification Name', Icons.card_giftcard),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(
                  orgController, 'Issuing Organization', Icons.account_balance),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(
                  credentialController, 'Credential ID', Icons.verified,
                  hintText: 'Optional'),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(urlController, 'URL', Icons.link,
                  hintText: 'Optional'),
              SizedBox(height: screenSize.height * 0.015),
              _buildDateField(
                  'Issue Date', issueDate, (date) => issueDate = date),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              if (issueDate != null) {
                final newCertification = Certification(
                  name: nameController.text,
                  issuingOrganization: orgController.text,
                  issueDate: issueDate,
                  credentialID: credentialController.text,
                  url: urlController.text,
                );
                BlocProvider.of<CandidateProfileBloc>(parentContext)
                    .add(AddCertification(newCertification));
                Navigator.pop(dialogContext);
              } else {
                print("not pressed");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCertificationDialog(
      BuildContext parentContext, Certification certification) {
    final nameController = TextEditingController(text: certification.name);
    final orgController =
        TextEditingController(text: certification.issuingOrganization);
    final credentialController =
        TextEditingController(text: certification.credentialID);
    final urlController = TextEditingController(text: certification.url);
    DateTime? issueDate = certification.issueDate;
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Certification',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  nameController, 'Certification Name', Icons.card_giftcard),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(
                  orgController, 'Issuing Organization', Icons.account_balance),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(
                  credentialController, 'Credential ID', Icons.verified,
                  hintText: 'Optional'),
              SizedBox(height: screenSize.height * 0.015),
              _buildTextField(urlController, 'URL', Icons.link,
                  hintText: 'Optional'),
              SizedBox(height: screenSize.height * 0.015),
              _buildDateField(
                  'Issue Date', issueDate, (date) => issueDate = date),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedCertification = Certification(
                id: certification.id,
                name: nameController.text,
                issuingOrganization: orgController.text,
                issueDate: issueDate,
                credentialID: credentialController.text,
                url: urlController.text,
              );
              BlocProvider.of<CandidateProfileBloc>(parentContext)
                  .add(UpdateCertification(updatedCertification));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext parentContext, String type, String id, String itemName) {
    final screenSize = MediaQuery.of(parentContext).size;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Delete',
            style: Theme.of(dialogContext).textTheme.displaySmall),
        content: Text('Are you sure you want to delete "$itemName"?',
            style: Theme.of(dialogContext).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: Theme.of(dialogContext).textTheme.bodyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightError,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              switch (type) {
                case 'education':
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(DeleteEducation(id));
                  break;
                case 'work-experience':
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(DeleteWorkExperience(id));
                  break;
                case 'internship':
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(DeleteInternship(id));
                  break;
                case 'project':
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(DeleteProject(id));
                  break;
                case 'certification':
                  BlocProvider.of<CandidateProfileBloc>(parentContext)
                      .add(DeleteCertification(id));
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hintText,
    bool isMultiLine = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: isMultiLine ? 3 : 1,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: AppColors.lightSurface,
        ),
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime? date, Function(DateTime?) onDateSelected) {
    final controller = TextEditingController(
      text: date != null ? DateFormat('dd/MM/yyyy').format(date) : '',
    );
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
      onTap: () async {
        final pickedDate = await _pickDate(context, initialDate: date);
        if (pickedDate != null) {
          controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          onDateSelected(pickedDate);
        }
      },
    );
  }

  Widget _buildDocumentUploadCard(
    BuildContext context, // This should be parentContext
    String label,
    String description,
    String type,
    IconData icon,
    Size screenSize,
    void Function(void Function()) setState,
  ) {
    bool isUploaded = documentUrl[type]!['url']!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(top: screenSize.height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300),
        color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded ? Colors.green.shade100 : Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.check : icon,
            color: isUploaded ? Colors.green.shade700 : Colors.blue.shade700,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          isUploaded ? 'Document uploaded successfully' : description,
          style: TextStyle(
            color: isUploaded ? Colors.green.shade700 : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        trailing: isUploaded
            ? IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue),
                onPressed: () {
                  setState(() {
                    documentUrl[type] = {'url': '', 'publicId': ''};
                  });
                },
              )
            : ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'pdf',
                      'doc',
                      'docx',
                      'jpeg',
                      'jpg',
                      'png'
                    ],
                  );

                  if (result != null &&
                      result.files.isNotEmpty &&
                      result.files.single.path != null) {
                    showDialog(
                      context: context, // Use parentContext
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 10)
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LoadingAnimationWidget.hexagonDots(
                                      color: Colors.blue, size: 40),
                                  SizedBox(height: 16),
                                  Text('Uploading $label...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    BlocProvider.of<CandidateProfileBloc>(context).add(
                        UploadDocumentEvent(
                            filePath: result.files.single.path!));
                    // Dialog will be closed by BlocListener
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text('Upload'),
              ),
      ),
    );
  }

  Widget _buildResumeUploadCard(
    BuildContext parentContext,
    String label,
    String description,
    String type,
    IconData icon,
    Size screenSize,
    Map<String, String> resumeUrl,
  ) {
    bool isUploaded = resumeUrl['url']!.isNotEmpty;
    final candidateProfileBloc =
        BlocProvider.of<CandidateProfileBloc>(parentContext);

    return Container(
      margin: EdgeInsets.only(top: screenSize.height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300),
        color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded ? Colors.green.shade100 : Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.check : icon,
            color: isUploaded ? Colors.green.shade700 : Colors.blue.shade700,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          isUploaded ? 'Resume uploaded successfully' : description,
          style: TextStyle(
            color: isUploaded ? Colors.green.shade700 : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx', 'jpeg', 'jpg', 'png'],
            );

            if (result != null && result.files.single.path != null) {
              // Show the loading dialog
              showDialog(
                context: parentContext,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return BlocListener<CandidateProfileBloc,
                      CandidateProfileState>(
                    bloc: candidateProfileBloc,
                    listener: (context, state) {
                      if (state is ProfileUpdateSuccess) {
                        Navigator.pop(
                            dialogContext); // Close the dialog on success
                        SnackBarUtils.showGreenSnackBar(
                            'Resume uploaded successfully', dialogContext);
                      } else if (state is ProfileError) {
                        Navigator.pop(
                            dialogContext); // Close the dialog on error
                        if (parentContext.mounted) {
                          SnackBarUtils.showRedSnackBar(
                              state.error, dialogContext);
                        }
                      }
                    },
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LoadingAnimationWidget.hexagonDots(
                                  color: Colors.blue, size: 40),
                              SizedBox(height: 16),
                              Text('Uploading Resume...',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );

              candidateProfileBloc
                  .add(UploadResume(filePath: result.files.single.path!));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(isUploaded ? 'Re-upload' : 'Upload'),
        ),
      ),
    );
  }
}
