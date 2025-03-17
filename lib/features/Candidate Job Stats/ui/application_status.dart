import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../Candidate Job/Apply Job Bloc/apply_job_bloc.dart';
import '../../../data/models/application/application_model.dart';
import '../../Candidate Job/model/candidate_job_model.dart';

class ApplicationStatus extends StatefulWidget {
  final CandidateJobModel job;

  const ApplicationStatus({Key? key, required this.job}) : super(key: key);

  @override
  State<ApplicationStatus> createState() => _ApplicationStatusState();
}

class _ApplicationStatusState extends State<ApplicationStatus> {
  @override
  void initState() {
    super.initState();
    context
        .read<ApplyJobBloc>()
        .add(FetchApplicationStatus(jobId: widget.job.id));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final brightness = Theme.of(context).brightness;
    final primaryColor = brightness == Brightness.light
        ? AppColors.lightPrimary
        : AppColors.darkPrimary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Application Status"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ApplyJobBloc, ApplyJobState>(
        listener: (context, state) {
          if (state is ApplicationsError) {
            print(state.error);
            SnackBarUtils.showRedSnackBar(state.error, context);
          }
          if (state is ApplicationsSuccess) {
            SnackBarUtils.showGreenSnackBar(state.message, context);
          }
        },
        builder: (context, state) {
          if (state is ApplicationsLoading) {
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: primaryColor,
                size: 40,
              ),
            );
          }

          if (state is ApplicationStatusLoaded) {
            return _buildApplicationStatusContent(
              context,
              state.applicationStatus,
              screenSize,
              primaryColor,
            );
          }

          return _buildErrorState(context, screenSize);
        },
      ),
    );
  }

  Widget _buildApplicationStatusContent(
      BuildContext context,
      Application application,
      Size screenSize,
      Color primaryColor,
      ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Summary Card
            _buildJobSummaryCard(context, screenSize),

            SizedBox(height: screenSize.height*0.03),

            // Application Information
            Text(
              "Application Information",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenSize.height*0.015),

            // Application ID and Date
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      "Application ID",
                      application.id.isNotEmpty ?
                      application.id.substring(0, min(application.id.length, 8)) + "..." :
                      "Pending",
                    ),
                    Divider(height: 24),
                    _buildInfoRow(
                      context,
                      "Applied On",
                      application.appliedDate != null ?
                      DateFormat('dd MMM yyyy').format(application.appliedDate!) :
                      "N/A",
                    ),
                    if (application.resume.isNotEmpty) ...[
                      Divider(height: 24),
                      _buildResumeRow(context, application.resume),
                    ],
                    Divider(height: 24),
                    _buildInfoRow(
                      context,
                      "Experience",
                      application.isFresher ? "Fresher" : "${application.experience.length} Previous Jobs",
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenSize.height*0.025),

            // Application Status
            Text(
              "Application Status",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenSize.height*0.015),

            _buildStatusCard(context, application.status, primaryColor),

            SizedBox(height: 24),

            // Contact Information
            _buildContactInfoCard(context, application.contactInfo, screenSize),

            SizedBox(height: 24),

            // Experience Information
            if (!application.isFresher && application.experience.isNotEmpty)
              _buildExperienceSection(context, application.experience, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSummaryCard(BuildContext context, Size screenSize) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.job.companyDetails.logo.url.isNotEmpty
                    ? Image.network(
                  widget.job.companyDetails.logo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.business, size: 30)),
                )
                    : Center(child: Icon(Icons.business, size: 30)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    widget.job.companyDetails.companyName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        "${widget.job.location.city}, ${widget.job.location.state}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResumeRow(BuildContext context, String resumeUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Resume",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            try {
              await launchUrl(Uri.parse(resumeUrl));
            } catch (e) {
              SnackBarUtils.showRedSnackBar(
                  "Couldn't open resume link", context);
            }
          },
          icon: Icon(Icons.remove_red_eye_outlined),
          label: Text("View"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, String status, Color primaryColor) {
    // Define status properties
    StatusInfo statusInfo = _getStatusInfo(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        statusInfo.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildApplicationProgressBar(context, status, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationProgressBar(
      BuildContext context,
      String status,
      Color primaryColor,
      ) {
    double progress;

    switch (status.toLowerCase()) {
      case 'pending':
        progress = 0.33;
        break;
      case 'shortlisted':
        progress = 0.67;
        break;
      case 'rejected':
        progress = 1.0;
        break;
      default:
        progress = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Application Progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: status.toLowerCase() == 'rejected' ?
                Colors.red :
                primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              status.toLowerCase() == 'rejected' ?
              Colors.red :
              primaryColor,
            ),
            minHeight: 8,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProgressStep(context, 'Applied', progress > 0, primaryColor),
            _buildProgressArrow(context),
            _buildProgressStep(context, 'Shortlisted', progress > 0.33, primaryColor),
            _buildProgressArrow(context),
            _buildProgressStep(
                context,
                status.toLowerCase() == 'rejected' ? 'Rejected' : 'Hired',
                progress > 0.67,
                status.toLowerCase() == 'rejected' ? Colors.red : primaryColor
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStep(
      BuildContext context,
      String label,
      bool isActive,
      Color activeColor,
      ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? activeColor : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Icon(
            isActive ? Icons.check : Icons.circle_outlined,
            color: isActive ? activeColor : Colors.grey[400],
            size: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive ?
            (label == 'Rejected' ? Colors.red : activeColor) :
            Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressArrow(BuildContext context) {
    return Icon(
      Icons.arrow_forward,
      color: Colors.grey[400],
      size: 20,
    );
  }

  Widget _buildContactInfoCard(
      BuildContext context,
      ContactInfo contactInfo,
      Size screenSize,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Contact Information",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildContactItem(
                  context,
                  Icons.email_outlined,
                  "Email",
                  contactInfo.email.isNotEmpty ? contactInfo.email : "Not provided",
                ),
                Divider(height: 24),
                _buildContactItem(
                  context,
                  Icons.phone_outlined,
                  "Phone",
                  contactInfo.phone.isNotEmpty ? contactInfo.phone : "Not provided",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 22,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection(
      BuildContext context,
      List<Experience> experiences,
      Size screenSize,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Work Experience",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: experiences.length,
          itemBuilder: (context, index) {
            final exp = experiences[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.designation.isNotEmpty ? exp.designation : "Position",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      exp.company.isNotEmpty ? exp.company : "Company",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (exp.duration.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Text(
                            exp.duration,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (exp.description.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        exp.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Size screenSize) {
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
            'Failed to load application status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<ApplyJobBloc>()
                  .add(FetchApplicationStatus(jobId: widget.job.id));
            },
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
          ),
        ],
      ),
    );
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }
}

class StatusInfo {
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

StatusInfo _getStatusInfo(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return StatusInfo(
        label: 'Under Review',
        description: 'Your application has been received and is under review by the recruiter.',
        icon: Icons.hourglass_top,
        color: Colors.amber,
      );
    case 'shortlisted':
      return StatusInfo(
        label: 'Shortlisted',
        description: 'Congratulations! Your profile has been shortlisted for the next round.',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      );
    case 'rejected':
      return StatusInfo(
        label: 'Not Selected',
        description: 'Thank you for your interest. We regret to inform you that your application was not selected at this time.',
        icon: Icons.cancel_outlined,
        color: Colors.red,
      );
    default:
      return StatusInfo(
        label: 'Processing',
        description: 'Your application is being processed.',
        icon: Icons.sync,
        color: Colors.blue,
      );
  }
}