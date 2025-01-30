import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/Job/job_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              // Handle edit job
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context, screenSize),
            _buildContentSection(context, screenSize),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, screenSize),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Size screenSize) {
    return Card(
      // padding: EdgeInsets.all(20),
      // decoration: BoxDecoration(
      //   //color: Colors.white,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.1),
      //       spreadRadius: 1,
      //       blurRadius: 5,
      //     ),
      //   ],
      // ),
      margin: EdgeInsets.all(5),
      elevation:1,
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
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                     //color: AppColors.deepPurple,
                    ),
                  ),
                ),
                _buildStatusChip(context,job.status,screenSize),
              ],
            ),
            SizedBox(height: screenSize.height*0.02),
            Text(
              job.description.companyOverview,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            _buildKeyDetails(context),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusChip(BuildContext context,String status,Size screenSize) {
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
                fontSize: screenSize.width*0.04
            )
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
          _buildSection(
            context,
            'Role Overview',
            job.description.roleOverview,
            Icons.work_outline,
          ),
          _buildResponsibilitiesSection(context),
          _buildQualificationsSection(context,screenSize),
          _buildBenefitsSection(context),
          _buildWorkEnvironmentSection(context),
          _buildGrowthSection(context),
          _buildApplicationSection(context),
          _buildAccessibilitySection(context),
          _buildInclusivitySection(context),
        ],
      ),
    );
  }

  Widget _buildKeyDetails(BuildContext context) {
    return Wrap(
      spacing: 35,
      runSpacing: 15,
      children: [
        _buildDetailChip(context,Icons.location_on, '${job.jobLocationDetails.city}, ${job.jobLocationDetails.state}'),
        _buildDetailChip(context,Icons.business_center, job.jobType),
        _buildDetailChip(context,Icons.timer, job.employmentType),
        _buildDetailChip(context,Icons.trending_up, job.experienceLevel),
        _buildDetailChip(context,Icons.calendar_today, 'Deadline: ${_formatDate(job.deadline)}'),
        _buildDetailChip(context,Icons.attach_money,
            '${job.description.salary.currency} ${job.description.salary.min}-${job.description.salary.max}k/year'),
      ],
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
            ...job.description.responsibilities.map((resp) => Padding(
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
            _buildQualificationItem(context, 'Education', job.description.qualifications.education),
            _buildQualificationItem(context, 'Experience', job.description.qualifications.experience),
            _buildSkillsGrid(context, job.description.qualifications.skills),
            if (job.description.qualifications.certifications.isNotEmpty)
              _buildCertifications(context, job.description.qualifications.certifications),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationItem(BuildContext context, String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid(BuildContext context, List<String> skills) {
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
          children: skills.map((skill) => Card(
            margin: EdgeInsets.all(0),
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSecondary.withOpacity(0.1):AppColors.lightDeepPurple.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            child: Padding(
              padding:   EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                skill,
                style: TextStyle(
                 // color: AppColors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCertifications(BuildContext context, List<String> certifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Text(
          'Preferred Certifications',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          //  color: AppColors.deepPurple,
          ),
        ),
        SizedBox(height: 8),
        ...certifications.map((cert) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.verified, size: 16),
              SizedBox(width: 8),
              Text(cert, style: Theme.of(context).textTheme.bodyMedium,),
            ],
          ),
        )),
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
            ...job.description.benefits.map((benefit) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(benefit, style: Theme.of(context).textTheme.bodyMedium,)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkEnvironmentSection(BuildContext context) {
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
            _buildWorkEnvironmentItem(context, 'Location', job.description.workEnvironment.location),
            _buildWorkEnvironmentItem(context, 'Schedule', job.description.workEnvironment.schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkEnvironmentItem(BuildContext context, String title, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(content, style: Theme.of(context).textTheme.bodyMedium,)),
        ],
      ),
    );
  }

  Widget _buildGrowthSection(BuildContext context) {
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
                Icon(Icons.trending_up),
                SizedBox(width: 8),
                Text(
                  'Growth Opportunities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(job.description.growthOpportunities, style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationSection(BuildContext context) {
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
                Icon(Icons.assignment_turned_in),
                SizedBox(width: 8),
                Text(
                  'Application Process',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              job.description.applicationInstructions,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            ...job.applicationProcess.steps.asMap().entries.map((entry) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary.withOpacity(0.1):AppColors.lightPrimary.withOpacity(0.1),
                    shape: CircleBorder(),
                    margin: EdgeInsets.all(0),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '${entry.key + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium,)),
                ],
              ),
            )),
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
            _buildAccessibilityItem(context, 'Workplace Accommodations',
                job.accessibilityFeatures.workplaceAccommodations.join(', ')),
            _buildAccessibilityItem(context, 'Communication Support',
                job.accessibilityFeatures.communicationSupport),
            _buildAccessibilityItem(context, 'Disability Friendliness',
                job.accessibilityFeatures.disabilityFriendliness),
            if (job.disabilityTypes.supportedDisabilities.isNotEmpty)
              _buildAccessibilityItem(context, 'Supported Disabilities',
                  job.disabilityTypes.supportedDisabilities.join(', ')),
          ],
        ),
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
          Text(content, style: Theme.of(context).textTheme.bodyMedium,),
        ],
      ),
    );
  }

  Widget _buildInclusivitySection(BuildContext context) {
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
                Icon(Icons.diversity_3),
                SizedBox(width: 8),
                Text(
                  'Inclusivity Statement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(job.inclusivityStatement),
            if (job.inclusiveHiringPractices.alternativeInterviewFormats.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Alternative Interview Formats Available:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              ...job.inclusiveHiringPractices.alternativeInterviewFormats.map((format) =>
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 16),
                        SizedBox(width: 8),
                        Text(format),
                      ],
                    ),
                  ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Size screenSize) {
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
                  // Handle view applicants
                },
                icon: Icon(Icons.people,color: AppColors.lightDivider,),
                label: Text('View ${job.applicants.length} Applicants'),
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

  // Helper widgets and methods...
  Widget _buildDetailChip(BuildContext context,IconData icon, String label) {
    return Card(
      //shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ?AppColors.lightBackground:AppColors.lightPrimary,),borderRadius: BorderRadius.circular(16)),
     // color: Theme.of(context).brightness == Brightness.dark ?AppColors.darkPrimary.withOpacity(0.1):AppColors.lightDeepPurple.withOpacity(0.1),
      margin: EdgeInsets.all(0),
      elevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 4),
          Text(
            label,

          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}