import 'package:android/features/Jobs/job_update_bloc/job_update_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../../data/models/Job/job_model.dart';

class EditJobScreen extends StatefulWidget {
  final JobModel job;
  final Function(JobModel) onJobUpdated;
  const EditJobScreen({super.key, required this.job, required this.onJobUpdated});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController overviewController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController salaryMinController;
  late TextEditingController salaryMaxController;
  late TextEditingController workspaceAccommodationsController;
  late TextEditingController interviewAccommodationsController;
  late TextEditingController _deadlineController;
   late DateTime? deadline;

  late String locationType;
  late String selectedEmploymentType;
  late String selectedExperienceLevel;

  late List<String> selectedSkills;
  late List<String> selectedResponsibilities;
  late List<String> selectedQualifications;
  late List<String> selectedBenefits;
  late List<String> selectedFacilityAccessibility;

  late  List<String> selectedSupportedDisabilities;

  String _selectedSkillCategory = 'Technical Skills';
  final _customSkillController = TextEditingController();
  // Predefined lists from schema
  final employmentTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Permanent',
    'Temporary',
    'Freelance'
  ];

  final locationTypes = ['Onsite', 'Remote', 'Hybrid'];

  final experienceLevels = ['Freshers', 'Intermediate', 'Professional'];

  final skillCategories = {
    'Technical Skills': [
      'Flutter', 'React', 'Node.js', 'Python', 'JavaScript', 'SQL', 'AWS', 'Docker',
      'Java', 'C++', 'iOS Development', 'Android Development', 'Machine Learning',
      'Data Analysis', 'DevOps', 'Cloud Computing'
    ],
    'Soft Skills': [
      'Communication', 'Leadership', 'Team Management', 'Problem Solving',
      'Critical Thinking', 'Time Management', 'Adaptability', 'Creativity',
      'Emotional Intelligence', 'Conflict Resolution', 'Decision Making'
    ],
    'Language Skills': [
      'English', 'Hindi', 'Spanish', 'French', 'German', 'Chinese', 'Japanese',
      'Sign Language'
    ],
    'Business Skills': [
      'Project Management', 'Strategic Planning', 'Business Analysis',
      'Marketing', 'Sales', 'Customer Service', 'Negotiation',
      'Financial Planning', 'Risk Management'
    ],
    'Industry-Specific Skills': [
      'Healthcare', 'Finance', 'Education', 'Manufacturing', 'Retail',
      'Hospitality', 'Construction', 'Automotive', 'Agriculture'
    ]
  };

  final facilityAccessibilityOptions = [
    'Wheelchair Access', 'Elevator Access', 'Accessible Parking', 'Accessible Restrooms'
  ];

  final supportedDisabilityTypes = [
    'Physical Disabilities',
    'Visual Impairments',
    'Hearing Impairments',
    'Cognitive Disabilities',
    'Neurological Conditions',
    'Other Disabilities'
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.job.title);
    overviewController = TextEditingController(text: widget.job.overview);
    addressController = TextEditingController(text: widget.job.location.address);
    cityController = TextEditingController(text: widget.job.location.city);
    stateController = TextEditingController(text: widget.job.location.state);
    countryController = TextEditingController(text: widget.job.location.country);
    salaryMinController = TextEditingController(text: widget.job.salary.min.toString());
    salaryMaxController = TextEditingController(text: widget.job.salary.max.toString());
    workspaceAccommodationsController = TextEditingController(text: widget.job.workspaceAccommodations);
    interviewAccommodationsController = TextEditingController(text: widget.job.interviewAccommodations);
    _deadlineController = TextEditingController(text:widget.job.deadline.toString() );
    locationType=widget.job.location.type;
    selectedEmploymentType=widget.job.employmentType;
    selectedExperienceLevel=widget.job.experienceLevel;
    selectedSkills=widget.job.skills;
    selectedResponsibilities=widget.job.responsibilities;
    selectedQualifications=widget.job.qualifications;
    selectedBenefits=widget.job.benefits;
    selectedFacilityAccessibility=widget.job.location.facilityAccessibility;
    selectedSupportedDisabilities=widget.job.disabilityTypes.supportedDisabilities;
    try {
      deadline = DateTime.parse(widget.job.deadline);
      _deadlineController.text = "${deadline!.day}/${deadline!.month}/${deadline!.year}";
    } catch (e) {
      deadline = DateTime.now().add(Duration(days: 7)); // Default to 7 days from now
      _deadlineController.text = "${deadline!.day}/${deadline!.month}/${deadline!.year}";
    }
  }
  
  @override
  void dispose() {
    titleController.dispose();
    overviewController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    salaryMinController.dispose();
    salaryMaxController.dispose();
    workspaceAccommodationsController.dispose();
    interviewAccommodationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("JobId ${widget.job.id}");
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Job'),
        actions: [
          TextButton(
            onPressed: _saveJob,
            child: Text('Save'),
          ),
        ],
      ),
      body: BlocConsumer<JobUpdateBloc, JobUpdateState>(
        listener: (context, state) {
          if (state is JobUpdateSuccess) {

            SnackBarUtils.showGreenSnackBar('Job Updated successfully', context);
            widget.onJobUpdated(state.job);
            Navigator.pop(context);
          } else if (state is JobUpdateError) {
            SnackBarUtils.showRedSnackBar(state.error, context);
          }
        },
        builder: (context, state) {
          return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInformationSection(screenSize),
                        _buildResponsibilitiesSection(screenSize),
                        _buildQualificationsSection(screenSize),
                        _buildSkillsSection(screenSize),
                        _buildLocationSection(screenSize),
                        _buildCompensationSection(screenSize),
                        _buildAccommodationsSection(screenSize),
                        _buildDeadlineSection(screenSize),
                        _buildUpdateButton(screenSize, state),
                      ],
                    ),
                  ),
                ),
                if (state is JobUpdateLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20),),
                  ),
              ],
            );

        },
      ),
    );
  }

  Widget _buildBasicInformationSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, screenSize, 'Basic Information', Icons.info_outline),
        SizedBox(height: screenSize.height*0.015,),
        _buildTextField(
          controller: titleController,
          label: 'Job Title',
          hint: 'e.g., Senior Software Engineer',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),
        _buildTextField(
          controller: overviewController,
          label: 'Overview',
          hint: 'Brief overview of the position',
          screenSize: screenSize,
          maxLines: 3,
        ),
        SizedBox(height: screenSize.height * 0.02),
      _buildDropdown(
        value: selectedEmploymentType,
        items: employmentTypes,
        label: 'Employment Type',
        onChanged: (value) => setState(() => selectedEmploymentType = value!),
        screenSize: screenSize,
      ),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: selectedExperienceLevel,
          items: experienceLevels,
          label: 'Experience Level',
          onChanged: (value) => setState(() => selectedExperienceLevel = value!),
          screenSize: screenSize,
        ),
      ],
    );
  }

  Widget _buildResponsibilitiesSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Responsibilities', Icons.work),
        _buildChipInputSection(
          '',
          'Add responsibility',
          selectedResponsibilities,
              (value) => setState(() => selectedResponsibilities.add(value)),
          screenSize,
        ),
      ],
    );
  }




  Widget _buildQualificationsSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Qualifications', Icons.school_outlined),
        _buildChipInputSection(
          '',
          'Add qualification',
          selectedQualifications,
              (value) => setState(() => selectedQualifications.add(value)),
          screenSize,
        ),
      ],
    );
  }

  Widget _buildSkillsSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Skills Required', Icons.psychology),
        SizedBox(height: screenSize.height * 0.02),

        // Skill category dropdown
        _buildDropdown(
          value: _selectedSkillCategory,
          items: skillCategories.keys.toList(),
          label: 'Skill Category',
          onChanged: (value) => setState(() => _selectedSkillCategory = value!),
          screenSize: screenSize,
        ),

        SizedBox(height: screenSize.height * 0.02),

        // Skills from selected category
        Text(
          'Available Skills',
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skillCategories[_selectedSkillCategory]!.map((skill) {
            final isSelected = selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedSkills.add(skill);
                  } else {
                    selectedSkills.remove(skill);
                  }
                });
              },
            );
          }).toList(),
        ),

        // Custom skill input
        SizedBox(height: screenSize.height * 0.02),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customSkillController,
                decoration: InputDecoration(
                  labelText: 'Add Custom Skill',
                  hintText: 'Enter a custom skill',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selectedSkills.add(value);
                      _customSkillController.clear();
                    });
                  }
                },
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            ElevatedButton(
              onPressed: () {
                if (_customSkillController.text.isNotEmpty) {
                  setState(() {
                    selectedSkills.add(_customSkillController.text);
                    _customSkillController.clear();
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        ),

        // Selected Skills Display
        if (selectedSkills.isNotEmpty) ...[
          SizedBox(height: screenSize.height * 0.02),
          Text(
            'Selected Skills',
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedSkills.map((skill) {
              return Chip(
                label: Text(skill),
                onDeleted: () {
                  setState(() {
                    selectedSkills.remove(skill);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Location Details', Icons.location_on_outlined),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: locationType,
          items: ['Onsite', 'Remote', 'Hybrid'],
          label: 'Location Type',
          onChanged: (value) => setState(() => locationType = value!),
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),
        _buildTextField(
          controller: addressController,
          label: 'Address',
          hint: 'Enter complete address',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: cityController,
                label: 'City',
                hint: 'Enter city',
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: _buildTextField(
                controller: stateController,
                label: 'State',
                hint: 'Enter state',
                screenSize: screenSize,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.01),
        _buildTextField(
          controller: cityController,
          label: 'Country',
          hint: 'Enter country',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
      ],
    );
  }

  Widget _buildCompensationSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.03),
        _buildSectionTitle(context, screenSize, 'Compensation & Benefits', Icons.attach_money),
        SizedBox(height: screenSize.height * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: salaryMinController,
                label: 'Min Salary (Rupees)',
                hint: '0',
                keyboardType: TextInputType.number,
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: _buildTextField(
                controller: salaryMaxController,
                label: 'Max Salary (Rupees)',
                hint: '0',
                keyboardType: TextInputType.number,
                screenSize: screenSize,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildChipInputSection(
          'Benefits',
          'Add benefit',
          selectedBenefits,
              (value) => setState(() => selectedBenefits.add(value)),
          screenSize,
        ),
      ],
    );
  }

  Widget _buildAccommodationsSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.03),
        _buildSectionTitle(context, screenSize, 'Accommodations & Accessibility', Icons.accessibility_new),
        SizedBox(height: screenSize.height * 0.01),

        // Workspace Accommodations
        _buildTextField(
          controller: workspaceAccommodationsController,
          label: 'Workspace Accommodations',
          hint: 'Describe available workplace accommodations',
          maxLines: 3,
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),

        // Interview Accommodations
        _buildTextField(
          controller: interviewAccommodationsController,
          label: 'Interview Accommodations',
          hint: 'Describe available interview accommodations',
          maxLines: 3,
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),

        // Facility Accessibility
        _buildMultiSelect(
          'Facility Accessibility',
          selectedFacilityAccessibility,
          facilityAccessibilityOptions,
          screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),

        // Supported Disabilities
        _buildMultiSelect(
          'Supported Disabilities',
          selectedSupportedDisabilities,
          supportedDisabilityTypes,
          screenSize,
        ),
      ],
    );
  }

  Widget _buildDeadlineSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Application Deadline', Icons.calendar_today),
        SizedBox(height: screenSize.height * 0.01),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: deadline ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                deadline = picked;
                _deadlineController.text = "${picked.day}/${picked.month}/${picked.year}";
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: 'Application Deadline',
                hintText: 'Select deadline',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an application deadline';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(Size screenSize, JobUpdateState state) {
    print(state);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
      child: ElevatedButton(
        onPressed: () {

          if (_formKey.currentState!.validate()) {
            final jobData = {
              'title': titleController.text,
              'overview': overviewController.text,
              'employmentType': selectedEmploymentType,
              'experienceLevel': selectedExperienceLevel,
              'responsibilities': selectedResponsibilities,
              'qualifications': selectedQualifications,
              'skills': selectedSkills,
              'location': {
                'type': locationType,
                'city': cityController.text,
                'state': stateController.text,
                'country': countryController.text,
                "facilityAccessibility":selectedFacilityAccessibility,
              },
              'salary': {
                'currency': 'Rupees',
                'min': int.parse(salaryMinController.text),
                'max': int.parse(salaryMaxController.text),
              },
              'benefits': selectedBenefits,
              'workspaceAccommodations': workspaceAccommodationsController.text,
              'interviewAccommodations': interviewAccommodationsController.text,
              'disabilityTypes': {
                'supportedDisabilities': selectedSupportedDisabilities,
              },
              'deadline': deadline!.toIso8601String(),
            };

         //   JobModel job = JobModel.fromJson(jobData);

           print("JodUpdate data $jobData");
            BlocProvider.of<JobUpdateBloc>(context).add(UpdateJobEvent(job: jobData, jobId: widget.job.id));
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, screenSize.height * 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Update Job',
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



  Widget _buildSectionTitle(BuildContext context, Size screenSize, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: screenSize.width * 0.06),
        SizedBox(width: screenSize.width * 0.02),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.045,
          ),
        ),
      ],
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Size screenSize,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildChipInputSection(
      String label,
      String hint,
      List<String> selectedItems,
      Function(String) onAdd,
      Size screenSize,
      ) {
    final TextEditingController controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.isNotEmpty ?Text(
          label,
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ):SizedBox(height: 0,),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    onAdd(value);
                    controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  controller.clear();
                }
              },
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.01),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedItems.map((item) {
            return Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  selectedItems.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelect(
      String label,
      List<String> selectedItems,
      List<String> allItems,
      Size screenSize,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allItems.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
    required Size screenSize,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }


  Future<void> _saveJob() async {
    // Create updated job model
    final updatedJob = JobModel(
      // Map all the updated fields here
    );

    try {
      // Save logic here
      Navigator.pop(context, updatedJob);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving job: $e')),
      );
    }

  }

}
