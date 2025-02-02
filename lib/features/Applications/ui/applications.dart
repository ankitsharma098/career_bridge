import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/application/application_model.dart';
import '../bloc/applications_bloc.dart';

class ApplicationsScreen extends StatefulWidget {
  final String jobId;
  const ApplicationsScreen({super.key, required this.jobId});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
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
      backgroundColor: Colors.grey[50],
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
              Text(
                'Candidates',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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
        final accepted = applications.applications.where((app) => app.status == 'accepted').length;
        final rejected = applications.applications.where((app) => app.status == 'rejected').length;

        return Card(
          margin: EdgeInsets.all(0),
        color: Theme.of(context).brightness==Brightness.dark ? AppColors.darkPrimary:AppColors.lightSecondary.withOpacity(0.9),
          // decoration: BoxDecoration(
            //   gradient: LinearGradient(
          //     colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //   ),
          //   borderRadius: BorderRadius.circular(16),
          // ),
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

                      color: Theme.of(context).brightness==Brightness.dark ? AppColors.darkPrimary:AppColors.lightBackground.withOpacity(0.2),

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
                    _buildStatItem(context, screenSize, 'Accepted', accepted, Colors.green),
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
      color: Theme.of(context).brightness==Brightness.dark ? AppColors.darkPrimary:AppColors.lightBackground.withOpacity(0.2),

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
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      builder: (context, state) {
        if (state is ApplicationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ApplicationLoaded) {
          return ListView.builder(
            itemCount: state.applications.applications.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final application = state.applications.applications[index];
              return ApplicationCard(
                application: application,
                screenSize: screenSize,
              );
            },
          );
        }

        if (state is ApplicationError) {
          return Center(child: Text(state.error));
        }

        return const SizedBox();
      },
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application application;
  final Size screenSize;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.screenSize,
  });

  Future<void> _openResume(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
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
                _buildCandidateInfo(),
                SizedBox(height: screenSize.height * 0.02),
                _buildSkills(),
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
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_${application.candidateInfo.id}',
            child: CircleAvatar(
              radius: screenSize.width * 0.06,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: application.candidateInfo.profilePic != null
                  ? NetworkImage(application.candidateInfo.profilePic!)
                  : null,
              child: application.candidateInfo.profilePic == null
                  ? Text(
                application.candidateInfo.fullName[0],
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: screenSize.width * 0.05,
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  application.candidateInfo.email,
                  style: TextStyle(
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
    );
  }

  Widget _buildAppliedDate() {
    final date = DateTime.parse(application.appliedDate.toString());
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
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

  Widget _buildResumeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openResume(application.resume),
        icon: Icon(Icons.description_outlined),
        label: Text('View Resume'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.symmetric(vertical: screenSize.width * 0.03),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
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
  Widget _buildCandidateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!application.isFresher && application.experience.isNotEmpty)
          ...[
            Text(
              'Experience',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: screenSize.width * 0.035,
                color: Colors.grey[700],
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
                      color: Colors.grey),
                  SizedBox(width: screenSize.width * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.designation,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                        Text(
                          '${exp.company} • ${exp.duration}',
                          style: TextStyle(
                            color: Colors.grey[600],
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: screenSize.width * 0.035,
            ),
          ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Icon(Icons.phone_outlined,
                size: screenSize.width * 0.04,
                color: Colors.grey),
            SizedBox(width: screenSize.width * 0.02),
            Text(
              application.contactInfo.phone,
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            context.read<ApplicationsBloc>().add(
              UpdateApplicationStatus(application.id, 'accepted'),
            );
          },
          child: const Text('Accept'),
        ),
        TextButton(
          onPressed: () {
            context.read<ApplicationsBloc>().add(
              UpdateApplicationStatus(application.id, 'rejected'),
            );
          },
          child: const Text('Reject'),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            context.read<ApplicationsBloc>().add(
              RemoveApplication(application.id),
            );
          },
        ),
      ],
    );
  }
  Widget _buildSkills() {
    if (application.candidateInfo.skills.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screenSize.width * 0.035,
            color: Colors.grey[700],
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
                color: AppColors.lightDeepPurple,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}