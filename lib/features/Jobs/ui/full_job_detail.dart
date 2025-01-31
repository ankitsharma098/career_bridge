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
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Job Details'),
        actions: [
          // In JobDetailsScreen, update the edit button's onPressed:
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => EditJobScreen(job: job),
              //   ),
              // );
            },
          ),
        ],
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
      bottomNavigationBar: _buildBottomBar(context, screenSize),
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
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(context, job.status, screenSize),
              ],
            ),
            SizedBox(height: screenSize.height * 0.02),
            Text(
              job.overview,
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
        _buildDetailChip(context, Icons.location_on, '${job.location.city}, ${job.location.state}'),
        _buildDetailChip(context, Icons.business_center, job.employmentType),
        _buildDetailChip(context, Icons.timer, job.experienceLevel),
        _buildDetailChip(context, Icons.trending_up, 'Deadline: ${_formatDate(job.deadline)}'),
        _buildDetailChip(context, Icons.attach_money,
            '${job.salary.currency} ${job.salary.min}-${job.salary.max}/year'),
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
          _buildSection(
            context,
            'Job Overview',
            job.overview,
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

  // Widget _buildKeyDetails(BuildContext context) {
  //   return Wrap(
  //     spacing: 35,
  //     runSpacing: 15,
  //     children: [
  //       _buildDetailChip(context,Icons.location_on, '${job.jobLocationDetails.city}, ${job.jobLocationDetails.state}'),
  //       _buildDetailChip(context,Icons.business_center, job.jobType),
  //       _buildDetailChip(context,Icons.timer, job.employmentType),
  //       _buildDetailChip(context,Icons.trending_up, job.experienceLevel),
  //       _buildDetailChip(context,Icons.calendar_today, 'Deadline: ${_formatDate(job.deadline)}'),
  //       _buildDetailChip(context,Icons.attach_money,
  //           '${job.description.salary.currency} ${job.description.salary.min}-${job.description.salary.max}k/year'),
  //     ],
  //   );
  // }

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
            ...job.responsibilities.map((resp) => Padding(
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
            ...job.qualifications.map((qual) => Padding(
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
          children: job.skills.map((skill) => Card(
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
            ...job.benefits.map((benefit) => Padding(
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
            _buildWorkEnvironmentItem(context, 'Work Type', job.location.type),
            _buildWorkEnvironmentItem(context, 'Address', job.location.address),
          ],
        ),
      ),
    );
  }
  // Widget _buildGrowthSection(BuildContext context) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     margin: EdgeInsets.only(bottom: 24),
  //     elevation: 0,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.trending_up),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Growth Opportunities',
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12),
  //           Text(job.description.growthOpportunities, style: Theme.of(context).textTheme.bodyMedium,),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildApplicationSection(BuildContext context) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     margin: EdgeInsets.only(bottom: 24),
  //     elevation: 0,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.assignment_turned_in),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Application Process',
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12),
  //           Text(
  //             job.description.applicationInstructions,
  //             style: Theme.of(context).textTheme.bodyMedium,
  //           ),
  //           SizedBox(height: 16),
  //           ...job.applicationProcess.steps.asMap().entries.map((entry) => Padding(
  //             padding: EdgeInsets.symmetric(vertical: 4),
  //             child: Row(
  //               children: [
  //                 Card(
  //                   elevation: 0,
  //                   color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary.withOpacity(0.1):AppColors.lightPrimary.withOpacity(0.1),
  //                   shape: CircleBorder(),
  //                   margin: EdgeInsets.all(0),
  //                   child: Padding(
  //                     padding: EdgeInsets.all(5),
  //                     child: Text(
  //                       '${entry.key + 1}',
  //                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 8),
  //                 Expanded(child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium,)),
  //               ],
  //             ),
  //           )),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
            _buildAccessibilityItem(context, 'Workspace Accommodations', job.workspaceAccommodations),
            _buildAccessibilityItem(context, 'Interview Accommodations', job.interviewAccommodations),
            if (job.disabilityTypes.supportedDisabilities.isNotEmpty)
              _buildAccessibilityItem(
                context,
                'Supported Disabilities',
                job.disabilityTypes.supportedDisabilities.join(', '),
              ),
            if (job.location.facilityAccessibility.isNotEmpty)
              _buildAccessibilityItem(
                context,
                'Facility Accessibility',
                job.location.facilityAccessibility.join(', '),
              ),
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

  // Widget _buildInclusivitySection(BuildContext context) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     margin: EdgeInsets.only(bottom: 24),
  //     elevation: 0,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.diversity_3),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Inclusivity Statement',
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12),
  //           Text(job.inclusivityStatement),
  //           if (job.inclusiveHiringPractices.alternativeInterviewFormats.isNotEmpty) ...[
  //             SizedBox(height: 16),
  //             Text(
  //               'Alternative Interview Formats Available:',
  //               style: TextStyle(fontWeight: FontWeight.w600),
  //             ),
  //             SizedBox(height: 4),
  //             ...job.inclusiveHiringPractices.alternativeInterviewFormats.map((format) =>
  //                 Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 2),
  //                   child: Row(
  //                     children: [
  //                       Icon(Icons.check, size: 16),
  //                       SizedBox(width: 8),
  //                       Text(format),
  //                     ],
  //                   ),
  //                 ),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
                icon: Icon(Icons.people, color: Colors.white),
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


// class EditJobScreen extends StatefulWidget {
//   final JobModel job;
//
//   const EditJobScreen({super.key, required this.job});
//
//   @override
//   State<EditJobScreen> createState() => _EditJobScreenState();
// }
//
// class _EditJobScreenState extends State<EditJobScreen> {
//   late TextEditingController titleController;
//   late TextEditingController companyOverviewController;
//   late TextEditingController roleOverviewController;
//   late TextEditingController experienceController;
//   late TextEditingController educationController;
//   late List<TextEditingController> responsibilitiesControllers;
//   late List<TextEditingController> skillsControllers;
//   late List<TextEditingController> certificationsControllers;
//   late List<TextEditingController> benefitsControllers;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeControllers();
//   }
//
//   void initializeControllers() {
//     titleController = TextEditingController(text: widget.job.title);
//     companyOverviewController = TextEditingController(text: widget.job.description.companyOverview);
//     roleOverviewController = TextEditingController(text: widget.job.description.roleOverview);
//     experienceController = TextEditingController(text: widget.job.description.qualifications.experience);
//     educationController = TextEditingController(text: widget.job.description.qualifications.education);
//
//     responsibilitiesControllers = widget.job.description.responsibilities
//         .map((r) => TextEditingController(text: r))
//         .toList();
//
//     skillsControllers = widget.job.description.qualifications.skills
//         .map((s) => TextEditingController(text: s))
//         .toList();
//
//     certificationsControllers = widget.job.description.qualifications.certifications
//         .map((c) => TextEditingController(text: c))
//         .toList();
//
//     benefitsControllers = widget.job.description.benefits
//         .map((b) => TextEditingController(text: b))
//         .toList();
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     companyOverviewController.dispose();
//     roleOverviewController.dispose();
//     experienceController.dispose();
//     educationController.dispose();
//     for (var controller in responsibilitiesControllers) {
//       controller.dispose();
//     }
//     for (var controller in skillsControllers) {
//       controller.dispose();
//     }
//     for (var controller in certificationsControllers) {
//       controller.dispose();
//     }
//     for (var controller in benefitsControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Edit Job'),
//         actions: [
//           TextButton(
//             onPressed: () => _saveJob(context),
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSection(
//               context,
//               'Basic Information',
//               Column(
//                 children: [
//                   _buildTextField(
//                     controller: titleController,
//                     label: 'Job Title',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: companyOverviewController,
//                     label: 'Company Overview',
//                     maxLines: 3,
//                   ),
//                 ],
//               ),
//             ),
//
//             _buildSection(
//               context,
//               'Role Details',
//               Column(
//                 children: [
//                   _buildTextField(
//                     controller: roleOverviewController,
//                     label: 'Role Overview',
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDynamicList(
//                     context,
//                     'Responsibilities',
//                     responsibilitiesControllers,
//                   ),
//                 ],
//               ),
//             ),
//
//             _buildSection(
//               context,
//               'Qualifications',
//               Column(
//                 children: [
//                   _buildTextField(
//                     controller: educationController,
//                     label: 'Education Requirements',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: experienceController,
//                     label: 'Experience Requirements',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDynamicList(
//                     context,
//                     'Required Skills',
//                     skillsControllers,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDynamicList(
//                     context,
//                     'Certifications',
//                     certificationsControllers,
//                   ),
//                 ],
//               ),
//             ),
//
//             _buildSection(
//               context,
//               'Benefits',
//               _buildDynamicList(
//                 context,
//                 'Benefits',
//                 benefitsControllers,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection(BuildContext context, String title, Widget content) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             content,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//       ),
//     );
//   }
//
//   Widget _buildDynamicList(
//       BuildContext context,
//       String label,
//       List<TextEditingController> controllers,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label),
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () {
//                 setState(() {
//                   controllers.add(TextEditingController());
//                 });
//               },
//             ),
//           ],
//         ),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: controllers.length,
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: controllers[index],
//                       decoration: InputDecoration(
//                         border: const OutlineInputBorder(),
//                         labelText: '${label} ${index + 1}',
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.remove_circle_outline),
//                     onPressed: () {
//                       setState(() {
//                         controllers[index].dispose();
//                         controllers.removeAt(index);
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   void _saveJob(BuildContext context) {
//     final updatedJob = {
//       'title': titleController.text,
//       'description': {
//         'companyOverview': companyOverviewController.text,
//         'roleOverview': roleOverviewController.text,
//         'responsibilities': responsibilitiesControllers
//             .map((controller) => controller.text)
//             .where((text) => text.isNotEmpty)
//             .toList(),
//         'qualifications': {
//           'education': educationController.text,
//           'experience': experienceController.text,
//           'skills': skillsControllers
//               .map((controller) => controller.text)
//               .where((text) => text.isNotEmpty)
//               .toList(),
//           'certifications': certificationsControllers
//               .map((controller) => controller.text)
//               .where((text) => text.isNotEmpty)
//               .toList(),
//         },
//         'benefits': benefitsControllers
//             .map((controller) => controller.text)
//             .where((text) => text.isNotEmpty)
//             .toList(),
//       },
//     };
//
//     // Here you would typically call your API to update the job
//     // For now, we'll just print the updated job and pop back
//     print(updatedJob);
//     Navigator.pop(context);
//   }
// }