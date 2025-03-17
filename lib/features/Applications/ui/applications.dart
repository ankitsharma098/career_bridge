import 'package:android/core/utils/snackBarUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../../data/models/application/application_model.dart';
import '../bloc/applications_bloc.dart';

class ApplicationsScreen extends StatefulWidget {
  final String jobId;
  const ApplicationsScreen({super.key, required this.jobId});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'pending', 'shortlisted', 'rejected'];
  @override
  void initState() {
    BlocProvider.of<ApplicationsBloc>(context).add(
        FetchApplications(jobId: widget.jobId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Applications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildApplicationStats(context, screenSize),
              SizedBox(height: screenSize.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Candidates',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkPrimary.withOpacity(0.2)
                          : AppColors.lightPrimary.withOpacity(0.1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        icon: const Icon(Icons.filter_list),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        items: _filters.map((String filter) {
                          return DropdownMenuItem<String>(
                            value: filter,
                            child: Text(
                              filter[0].toUpperCase() + filter.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              Expanded(
                child: _buildApplicationsList(context, screenSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationStats(BuildContext context, Size screenSize) {
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      builder: (context, state) {
        if (state is! ApplicationLoaded) return const SizedBox();

        final applications = state.applications;
        final pending = applications.applications.where((app) => app.status == 'pending').length;
        final accepted = applications.applications.where((app) => app.status == 'shortlisted').length;
        final rejected = applications.applications.where((app) => app.status == 'rejected').length;

        return Card(
          margin: EdgeInsets.all(0),
        color: Theme.of(context).brightness==Brightness.dark ? AppColors.darkSurface.withOpacity(0.5):AppColors.lightSecondary.withOpacity(0.9),

          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applications Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Card(
                      margin:EdgeInsets.all(0) ,

                      color: Theme.of(context).brightness==Brightness.dark ? AppColors.darkPrimary.withOpacity(0.2):AppColors.lightBackground.withOpacity(0.2),

                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.03,
                          vertical: screenSize.width * 0.01,
                        ),
                        child: Text(
                          'Total: ${applications.totalApplications}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, screenSize, 'Pending', pending, Colors.amber),
                    _buildStatItem(context, screenSize, 'Shortlisted', accepted, Colors.green),
                    _buildStatItem(context, screenSize, 'Rejected', rejected, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, Size screenSize, String label, int count, Color color) {
    return Card(
      margin:EdgeInsets.all(0) ,
      color: Theme.of(context).brightness==Brightness.dark ?AppColors.darkPrimary.withOpacity(0.2):AppColors.lightBackground.withOpacity(0.2),

      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: screenSize.width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, Size screenSize) {
    return BlocConsumer<ApplicationsBloc, ApplicationsState>(
      listener: (context, state) {
        if (state is ApplicationError) {
          return SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
        if(state is ApplicationStatusChangedSuccess){
          return SnackBarUtils.showGreenSnackBar(state.message, context);
        }
      },
      builder: (context, state) {
        if (state is ApplicationLoading) {
          return Center(child: LoadingAnimationWidget.hexagonDots(color: Theme.of(context).brightness ==Brightness.dark ?AppColors.lightPrimary :AppColors.lightPrimary, size: 30),);

        }

        if (state is ApplicationLoaded) {
          final filteredApplications = _selectedFilter == 'all'
              ? state.applications.applications
              : state.applications.applications
              .where((app) => app.status.toLowerCase() == _selectedFilter)
              .toList();

          return filteredApplications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No $_selectedFilter applications found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                  itemCount: filteredApplications.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final application = filteredApplications[index];
                    return ApplicationCard(
                      application: application,
                      screenSize: screenSize,
                      jobId: widget.jobId,
                    );
                  },
                );
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
}

class ApplicationCard extends StatelessWidget {
  final Application application;
  final String jobId;
  final Size screenSize;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.screenSize,
    required this.jobId,
  });

  Future<void> _openResume(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,  // Try using external application mode
        );
        if (!launched) {
          if (context.mounted) {
            SnackBarUtils.showRedSnackBar("Could not open the resume. Please try again later.", context);
          }
        }
      } else {
        if (context.mounted) {
          SnackBarUtils.showRedSnackBar("Unable to open the resume URL", context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showRedSnackBar("rror opening resume: ${e.toString()}", context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildHeader(context),
          Divider(),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppliedDate(),
                SizedBox(height: screenSize.height * 0.02),
                _buildCandidateInfo(context),
                SizedBox(height: screenSize.height * 0.02),
                _buildSkills(context),
                SizedBox(height: screenSize.height * 0.02),
                _buildResumeButton(context),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Row(
          children: [
            Hero(
              tag: 'profile_${application.candidateInfo.id}',
              child: CircleAvatar(
                radius: screenSize.width * 0.06,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary.withOpacity(0.3): AppColors.lightPrimary.withOpacity(0.3),
                backgroundImage: application.candidateInfo.profilePic != null
                    ? NetworkImage(application.candidateInfo.profilePic!)
                    : null,
                child: application.candidateInfo.profilePic == null
                    ? Text(
                  application.candidateInfo.fullName[0],
                  style: TextStyle(
                    color:Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary: AppColors.lightPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.045,
                  ),
                )
                    : null,
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.candidateInfo.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    application.candidateInfo.email,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: screenSize.width * 0.035,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedDate() {
    final date = application.appliedDate;
    final formattedDate = DateFormat('MMM dd, yyyy').format(date!);
    final timeAgo = timeago.format(date);

    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          'Applied $timeAgo ($formattedDate)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: screenSize.width * 0.035,
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!application.isFresher && application.experience.isNotEmpty)
          ...[
            Text(
              'Experience',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: screenSize.width * 0.035,
                //color: Colors.grey[700],
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            ...application.experience.map((exp) => Padding(
              padding: EdgeInsets.only(bottom: screenSize.height * 0.01),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.work_outline,
                    size: screenSize.width * 0.04,
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.designation,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                        Text(
                          '${exp.company} • ${exp.duration}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            // color: AppColors.darkSurface.withOpacity(0.6),
                            fontSize: screenSize.width * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ]
        else
          Text(
            'Fresher',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.darkSurface.withOpacity(0.6),
              fontSize: screenSize.width * 0.035,
            ),
          ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Icon(Icons.phone_outlined,
              size: screenSize.width * 0.04,
            ),
            SizedBox(width: screenSize.width * 0.02),
            Text(
              application.contactInfo.phone,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: screenSize.width * 0.035,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkills(BuildContext context) {
    if (application.candidateInfo.skills.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: screenSize.width * 0.035,
           // color: Colors.grey[700],
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Wrap(
          spacing: screenSize.width * 0.02,
          runSpacing: screenSize.height * 0.01,
          children: application.candidateInfo.skills.map((skill) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
              vertical: screenSize.height * 0.005,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightDeepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(screenSize.width * 0.01),
            ),
            child: Text(
              skill,
              style: TextStyle(
                fontSize: screenSize.width * 0.03,
               color:  Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary: AppColors.lightPrimary,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResumeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openResume(context,application.resume),
        icon: Icon(Icons.description_outlined,color: AppColors.lightSurface,),
        label: Text('View Resume'),
        style: ElevatedButton.styleFrom(
        //  backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.symmetric(vertical: screenSize.width * 0.03),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    // Only show actions for pending applications
    if (application.status.toLowerCase() == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              context.read<ApplicationsBloc>().add(
                UpdateApplicationStatus(application.id, 'shortlisted', jobId),
              );
            },
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () {
              context.read<ApplicationsBloc>().add(
                UpdateApplicationStatus(application.id, 'rejected', jobId),
              );
            },
            child: const Text('Reject'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<ApplicationsBloc>().add(
                RemoveApplication(application.id, jobId),
              );
            },
          ),
        ],
      );
    } else if (application.status.toLowerCase() == 'shortlisted' ||
        application.status.toLowerCase() == 'rejected') {
      // For shortlisted or rejected applications, only show delete option
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<ApplicationsBloc>().add(
                RemoveApplication(application.id, jobId),
              );
            },
          ),
        ],
      );
    }

    // Return empty container if status is unknown
    return Container();
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    switch (application.status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'accepted':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: chipColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: screenSize.width * 0.015
        ),
        child: Text(
          application.status.toUpperCase(),
          style: Theme
              .of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
              color: chipColor,
              fontSize: screenSize.width * 0.04
          ),
        ),
      ),
    );
  }



}