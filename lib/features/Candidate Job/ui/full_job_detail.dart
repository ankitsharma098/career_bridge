import 'package:android/features/Candidate%20Job/model/candidate_job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Candidate Job Stats/ui/application_status.dart';
import '../Apply Job Bloc/apply_job_bloc.dart';
import 'apply_job.dart';

class CandidateJobDetails extends StatefulWidget {
  final CandidateJobModel job;
  final bool isAlreadyApplied;

  const CandidateJobDetails({super.key, required this.job, required this.isAlreadyApplied});

  @override
  State<CandidateJobDetails> createState() => _CandidateJobDetailsState();
}

class _CandidateJobDetailsState extends State<CandidateJobDetails> {

  late CandidateJobModel currentJob;

  @override
  void initState() {

    super.initState();
    currentJob = widget.job;
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
        title: Text('Job Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenSize.height*0.01,),
            _buildHeaderSection(context, screenSize),
            _buildContentSection(context, screenSize),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, screenSize,widget.job),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Size screenSize) {
    return Card(
      margin: EdgeInsets.all(5),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentJob.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(context, currentJob.status, screenSize),
              ],
            ),
            SizedBox(height: screenSize.height * 0.02),
            Text(
              currentJob.overview,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            _buildKeyDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyDetails(BuildContext context) {
    return Wrap(
      spacing: 35,
      runSpacing: 15,
      children: [
        _buildDetailChip(context, Icons.location_on, '${currentJob.location.city}, ${currentJob.location.state}'),
        _buildDetailChip(context, Icons.business_center, currentJob.employmentType),
        _buildDetailChip(context, Icons.timer, currentJob.experienceLevel),
        _buildDetailChip(context, Icons.trending_up, 'Deadline: ${_formatDate(currentJob.deadline)}'),
        _buildDetailChip(context, Icons.attach_money,
            '${currentJob.salary.currency} ${currentJob.salary.min}-${currentJob.salary.max}/year'),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status, Size screenSize) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'open':
        chipColor = Colors.green;
        break;
      case 'closed':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(0),
      color: chipColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: chipColor,
            fontSize: screenSize.width * 0.04,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, Size screenSize) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanySection(context),
          _buildSection(
            context,
            'Job Overview',
            currentJob.overview,
            Icons.work_outline,
          ),
          _buildResponsibilitiesSection(context),
          _buildQualificationsSection(context, screenSize),
          _buildBenefitsSection(context),
          _buildWorkEnvironmentSection(context),
          _buildAccessibilitySection(context),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsibilitiesSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment),
                SizedBox(width: 8),
                Text(
                  'Responsibilities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...currentJob.responsibilities.map((resp) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(resp, style: Theme.of(context).textTheme.bodyMedium,)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationsSection(BuildContext context,Size screenSize) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school),
                SizedBox(width: 8),
                Text(
                  'Qualifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height*0.01),
            ...currentJob.qualifications.map((qual) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(qual, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            )),
            SizedBox(height: 16),
            _buildSkillsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(BuildContext context,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: currentJob.skills.map((skill) => Card(
            margin: EdgeInsets.all(0),
            color: Theme.of(context).brightness == Brightness.dark ?
            Colors.grey.shade700 : Colors.grey.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                skill,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard),
                SizedBox(width: 8),
                Text(
                  'Benefits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...currentJob.benefits.map((benefit) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(benefit, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkEnvironmentSection(BuildContext context) {
    print("addres ${widget.job.location.address}");
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business),
                SizedBox(width: 8),
                Text(
                  'Work Environment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildWorkEnvironmentItem(context, 'Work Type', currentJob.location.type),
            _buildWorkEnvironmentItem(context, 'Address', currentJob.location.address),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilitySection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.accessibility_new),
                SizedBox(width: 8),
                Text(
                  'Accessibility Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildAccessibilityItem(context, 'Workspace Accommodations', currentJob.workspaceAccommodations),
            _buildAccessibilityItem(context, 'Interview Accommodations', currentJob.interviewAccommodations),
            if (currentJob.disabilityTypes.supportedDisabilities.isNotEmpty)
              _buildAccessibilityItem(
                context,
                'Supported Disabilities',
                currentJob.disabilityTypes.supportedDisabilities.join(', '),
              ),
            if (currentJob.location.facilityAccessibility.isNotEmpty)
              _buildAccessibilityItem(
                context,
                'Facility Accessibility',
                currentJob.location.facilityAccessibility.join(', '),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkEnvironmentItem(BuildContext context, String title, String content) {
    print("Address $content");
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(content, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildAccessibilityItem(BuildContext context, String title, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Size screenSize,CandidateJobModel job) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                 widget.isAlreadyApplied ? Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => BlocProvider(
                       create: (context) => ApplyJobBloc(),
                       child: ApplicationStatus(job:job),
                     ),
                   ),
                 ): Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ApplyJobBloc(),
                        child: ApplyJobScreen(jobId: job.id),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.people, color: Colors.white),
                label:  widget.isAlreadyApplied ?Text('Application Status') :Text('Apply now'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              onPressed: () {
                // Handle share job
              },
              icon: Icon(Icons.share),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCompanySection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business),
                SizedBox(width: 8),
                Text(
                  'Company Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                if (currentJob.companyDetails.logo.url.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      currentJob.companyDetails.logo.url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.business, size: 40),
                          ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business, size: 40),
                  ),
                SizedBox(width: 16),
                // Company Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentJob.companyDetails.companyName.isNotEmpty)
                        Text(
                          currentJob.companyDetails.companyName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (currentJob.companyDetails.industryType.isNotEmpty)
                        _buildCompanyDetailItem(context, "Industry", currentJob.companyDetails.industryType),
                      if (currentJob.companyDetails.website.isNotEmpty)
                        _buildCompanyDetailItem(context, "Website", currentJob.companyDetails.website),
                      if (currentJob.companyDetails.location.city.isNotEmpty ||
                          currentJob.companyDetails.location.state.isNotEmpty ||
                          currentJob.companyDetails.location.country.isNotEmpty)
                        _buildCompanyDetailItem(
                            context,
                            "Location",
                            [
                              currentJob.companyDetails.location.city,
                              currentJob.companyDetails.location.state,
                              currentJob.companyDetails.location.country
                            ].where((element) => element.isNotEmpty).join(", ")
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Optional: Add a Visit Website button if website URL is available
            if (currentJob.companyDetails.website.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    // You can implement URL launching here
                    // Using url_launcher package
                  },
                  icon: Icon(Icons.open_in_new),
                  label: Text('Visit Website'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyDetailItem(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets and methods...
  Widget _buildDetailChip(BuildContext context, IconData icon, String label) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}

