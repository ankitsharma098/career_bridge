import 'package:android/core/utils/snackBarUtils.dart';
import 'package:android/data/models/Job/job_model.dart';
import 'package:android/features/Jobs/job_create_bloc/job_create_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Previous JobCreationEvent, JobCreationState, and JobCreationBloc remain the same

class CreateJobScreen extends StatefulWidget {
  final Function(JobModel) onJobCreated;
  const CreateJobScreen({super.key, required this.onJobCreated});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

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
  final _deadlineController = TextEditingController();
  DateTime? _deadline;
  String _selectedSkillCategory = 'Technical Skills';
  final _customSkillController = TextEditingController();

  // Basic Information Controllers
  final _titleController = TextEditingController();
  final _overviewController = TextEditingController();

  // Location Controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  // Salary Controllers
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  // Accommodation Controllers
  final _workspaceAccommodationsController = TextEditingController();
  final _interviewAccommodationsController = TextEditingController();

  // Lists for multiple selections
  List<String> selectedSkills = [];
  List<String> selectedResponsibilities = [];
  List<String> selectedQualifications = [];
  List<String> selectedBenefits = [];
  List<String> selectedFacilityAccessibility = [];
  List<String> selectedSupportedDisabilities = [];

  // Dropdown selections
  String locationType = 'Onsite';
  String selectedEmploymentType = 'Full-time';
  String selectedExperienceLevel = 'Freshers';

  // Date
  DateTime? deadline;

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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<JobCreateBloc, JobCreateState>(
        listener: (context, state) {
          if (state is JobCreationSuccess) {
            widget.onJobCreated(state.job);
            SnackBarUtils.showGreenSnackBar('Job Posted successfully', context);
            Navigator.pop(context);
          } else if (state is JobCreationError) {
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
                      _buildSubmitButton(screenSize, state),
                    ],
                  ),
                ),
              ),
              if (state is JobCreationLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
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
        _buildTextField(
          controller: _titleController,
          label: 'Job Title',
          hint: 'e.g., Senior Software Engineer',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),
        _buildTextField(
          controller: _overviewController, // New controller for overview
          label: 'Overview',
          hint: 'Brief overview of the position',
          maxLines: 3,
          screenSize: screenSize,
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


  Widget _buildQualificationsSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Qualifications', Icons.school_outlined),
        _buildChipInputSection(
          '',
          'Add Qualifications',
          selectedQualifications,
              (value) => setState(() => selectedQualifications.add(value)),
          screenSize,
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
          controller: _addressController,
          label: 'Address',
          hint: 'Enter complete address',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State',
                hint: 'Enter state',
                screenSize: screenSize,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.01),
        _buildTextField(
          controller: _countryController,
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
                controller: _salaryMinController,
                label: 'Min Salary (Rupees)',
                hint: '0',
                keyboardType: TextInputType.number,
                screenSize: screenSize,
              ),
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: _buildTextField(
                controller: _salaryMaxController,
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
          controller: _workspaceAccommodationsController,
          label: 'Workspace Accommodations',
          hint: 'Describe available workplace accommodations',
          maxLines: 3,
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.01),

        // Interview Accommodations
        _buildTextField(
          controller: _interviewAccommodationsController,
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
              initialDate: _deadline ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _deadline = picked;
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


  Widget _buildSubmitButton(Size screenSize, JobCreateState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
      child: ElevatedButton(
        onPressed: state is JobCreationLoading
            ? null
            : () {

          if (_formKey.currentState!.validate()) {
            final jobData = {
              'title': _titleController.text,
              'overview': _overviewController.text,
              'employmentType': selectedEmploymentType,
              'experienceLevel': selectedExperienceLevel,
              'responsibilities': selectedResponsibilities,
              'qualifications': selectedQualifications,
              'skills': selectedSkills,
              'location': {
                'type': locationType,
                'city': _cityController.text,
                'state': _stateController.text,
                'country': _countryController.text,
                "facilityAccessibility":selectedFacilityAccessibility,
              },
              'salary': {
                'currency': 'Rupees',
                'min': int.parse(_salaryMinController.text),
                'max': int.parse(_salaryMaxController.text),
              },
              'benefits': selectedBenefits,
              'workspaceAccommodations': _workspaceAccommodationsController.text,
              'interviewAccommodations': _interviewAccommodationsController.text,
              'disabilityTypes': {
                'supportedDisabilities': selectedSupportedDisabilities,
              },
              'deadline': _deadline?.toIso8601String() ?? '',
            };

            context.read<JobCreateBloc>().add(
              SubmitJobEvent(
                job: jobData,
              ),
           );
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, screenSize.height * 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Create Job',
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



  // @override
  // void dispose() {
  //   _titleController.dispose();
  //   _roleOverviewController.dispose();
  //   _contentController.dispose();
  //   _addressController.dispose();
  //   _cityController.dispose();
  //   _stateController.dispose();
  //   _countryController.dispose();
  //   _salaryMinController.dispose();
  //   _salaryMaxController.dispose();
  //   _companyOverviewController.dispose();
  //   _growthOpportunitiesController.dispose();
  //   _applicationInstructionsController.dispose();
  //   _additionalSupportDetailsController.dispose();
  //   _inclusivityStatementController.dispose();
  //   super.dispose();
  // }
}