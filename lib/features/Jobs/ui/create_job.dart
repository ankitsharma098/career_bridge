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

  // Basic Information Controllers
  final _titleController = TextEditingController();
  final _roleOverviewController = TextEditingController();
  final _contentController = TextEditingController();

  // Location Controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  // Salary Controllers
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  // Additional Information Controllers
  final _companyOverviewController = TextEditingController();
  final _growthOpportunitiesController = TextEditingController();
  final _applicationInstructionsController = TextEditingController();
  final _additionalSupportDetailsController = TextEditingController();
  final _inclusivityStatementController = TextEditingController();

  // Lists for multiple selections
  List<String> selectedSkills = [];
  List<String> selectedResponsibilities = [];
  List<String> selectedBenefits = [];
  List<String> selectedRequirements = [];
  List<String> selectedWorkplaceAccommodations = [];
  List<String> selectedSupportedDisabilities = [];
  List<String> selectedAlternativeInterviewFormats = [];

  // Dropdown selections
  String selectedJobType = 'Full-time';
  String selectedJobLocation = 'Onsite';
  String selectedEmploymentType = 'Permanent';
  String selectedExperienceLevel = 'Freshers';
  String selectedCommunicationSupport = 'Text-based Communication';
  String selectedDisabilityFriendliness = 'Commitment to Inclusion';

  // Boolean selections
  bool personalAssistanceAvailable = false;
  bool specialEquipmentProvided = false;
  bool blindRecruitment = false;

  // Date
  DateTime? deadline;

  // Predefined lists from schema
  final jobTypes = ['Full-time', 'Part-time', 'Internship', 'Contract'];
  final jobLocations = ['Onsite', 'Remote', 'Hybrid'];
  final employmentTypes = ['Permanent', 'Temporary', 'Freelance', 'Consultant'];
  final experienceLevels = ['Freshers', 'Intermediate', 'Professional'];

  final workplaceAccommodations = [
    'Wheelchair Accessible',
    'Sign Language Interpreter',
    'Assistive Technology',
    'Flexible Work Hours',
    'Remote Work Options',
    'Adaptive Equipment',
    'Screen Reader Compatible',
    'Braille Resources',
    'Quiet Work Spaces',
    'Ergonomic Workstation'
  ];

  final communicationSupports = [
    'Text-based Communication',
    'Visual Communication',
    'Sign Language Support',
    'Closed Captioning',
    'Screen Reader Friendly'
  ];

  final disabilityFriendlinessOptions = [
    'Fully Accessible',
    'Partially Accessible',
    'Commitment to Inclusion',
    'Adaptive Workplace'
  ];

  final supportedDisabilities = [
    'Physical Disabilities',
    'Visual Impairments',
    'Hearing Impairments',
    'Neurodivergent Conditions',
    'Cognitive Disabilities',
    'Mental Health Conditions'
  ];

  final alternativeInterviewFormats = [
    'Written Interviews',
    'Video Interviews',
    'Alternative Communication Methods'
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Job',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<JobCreateBloc, JobCreateState>(
        listener: (context, state) {
          if (state is JobCreationSuccess) {
            widget.onJobCreated(state.job);
            SnackBarUtils.showGreenSnackBar('Jog Posted successfully', context);
        //    Navigator.pop(context);
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
                      _buildJobDetailsSection(screenSize),
                      _buildLocationSection(screenSize),
                      _buildCompensationSection(screenSize),
                      _buildQualificationsSection(screenSize),
                      _buildAccessibilitySection(screenSize),
                      _buildInclusiveHiringSection(screenSize),
                      _buildSubmitButton(screenSize, state),
                    ],
                  ),
                ),
              ),
              if (state is JobCreationLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(child: CircularProgressIndicator()),
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
        SizedBox(height: screenSize.height * 0.02),
        _buildTextField(
          controller: _titleController,
          label: 'Job Title',
          hint: 'e.g., Senior Software Engineer',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: selectedJobType,
          items: jobTypes,
          label: 'Job Type',
          onChanged: (value) => setState(() => selectedJobType = value!),
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: selectedJobLocation,
          items: jobLocations,
          label: 'Job Location',
          onChanged: (value) => setState(() => selectedJobLocation = value!),
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
      ],
    );
  }

  Widget _buildJobDetailsSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.03),
        _buildSectionTitle(context, screenSize, 'Job Details', Icons.work_outline),
        SizedBox(height: screenSize.height * 0.02),
        _buildTextField(
          controller: _roleOverviewController,
          label: 'Role Overview',
          hint: 'Describe the role and its importance',
          maxLines: 3,
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildTextField(
          controller: _contentController,
          label: 'Detailed Content',
          hint: 'Provide comprehensive information about the role',
          maxLines: 5,
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildChipInputSection(
          'Key Responsibilities',
          'Add responsibility',
          selectedResponsibilities,
              (value) => setState(() => selectedResponsibilities.add(value)),
          screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildChipInputSection(
          'Requirements',
          'Add requirement',
          selectedRequirements,
              (value) => setState(() => selectedRequirements.add(value)),
          screenSize,
        ),
      ],
    );
  }

  Widget _buildLocationSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.03),
        _buildSectionTitle(context, screenSize, 'Location Details', Icons.location_on_outlined),
        SizedBox(height: screenSize.height * 0.02),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter complete address',
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
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
        SizedBox(height: screenSize.height * 0.02),
        _buildTextField(
          controller: _countryController,
          label: 'Country',
          hint: 'Enter country',
          screenSize: screenSize,
        ),
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

  Widget _buildQualificationsSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.03),
        _buildSectionTitle(context, screenSize, 'Qualifications', Icons.school_outlined),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: selectedExperienceLevel,
          items: experienceLevels,
          label: 'Experience Level',
          onChanged: (value) => setState(() => selectedExperienceLevel = value!),
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildMultiSelect(
          'Required Skills',
          selectedSkills,
          ['Flutter', 'React', 'Node.js', 'Python', 'JavaScript', 'SQL', 'AWS', 'Docker'],
          screenSize,
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.03),
        _buildSectionTitle(context, screenSize, 'Accessibility Features', Icons.accessibility_new),
        SizedBox(height: screenSize.height * 0.02),
        _buildMultiSelect(
          'Workplace Accommodations',
          selectedWorkplaceAccommodations,
          workplaceAccommodations,
          screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: selectedCommunicationSupport,
          items: communicationSupports,
          label: 'Communication Support',
          onChanged: (value) => setState(() => selectedCommunicationSupport = value!),
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildDropdown(
          value: selectedDisabilityFriendliness,
          items: disabilityFriendlinessOptions,
          label: 'Disability Friendliness',
          onChanged: (value) => setState(() => selectedDisabilityFriendliness = value!),
          screenSize: screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildMultiSelect(
          'Supported Disabilities',
          selectedSupportedDisabilities,
          supportedDisabilities,
          screenSize,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildTextField(
          controller: _inclusivityStatementController,
          label: 'Inclusivity Statement',
          hint: 'Enter your company\'s inclusivity statement',
          maxLines: 3,
          screenSize: screenSize,
        ),
      ],
    );
  }

  Widget _buildInclusiveHiringSection(Size screenSize) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.03),
          _buildSectionTitle(context, screenSize, 'Inclusive Hiring Practices', Icons.diversity_3),
          SizedBox(height: screenSize.height * 0.02),
          _buildSwitchListTile(
          'Blind Recruitment',
          'Hide candidate personal information during initial screening',
          blindRecruitment,
          (value) => setState(() => blindRecruitment = value),
          ),
          _buildSwitchListTile(
          'Personal Assistance Available',
          'Provide personal assistance during the hiring process',
            personalAssistanceAvailable,
                (value) => setState(() => personalAssistanceAvailable = value),
          ),
          _buildSwitchListTile(
            'Special Equipment Provided',
            'Provide special equipment during the hiring process',
            specialEquipmentProvided,
                (value) => setState(() => specialEquipmentProvided = value),
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildMultiSelect(
            'Alternative Interview Formats',
            selectedAlternativeInterviewFormats,
            alternativeInterviewFormats,
            screenSize,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildTextField(
            controller: _additionalSupportDetailsController,
            label: 'Additional Support Details',
            hint: 'Describe any additional support available',
            maxLines: 3,
            screenSize: screenSize,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildDatePicker(screenSize),
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
            context.read<JobCreateBloc>().add(
              SubmitJobEvent(
                job: {
                  'title': _titleController.text,
                  'description': {
                    'roleOverview': _roleOverviewController.text,
                    'content': _contentController.text,
                    'responsibilities': selectedResponsibilities,
                    'qualifications': {
                      'skills': selectedSkills,
                    },
                    'benefits': selectedBenefits,
                    'companyOverview': _companyOverviewController.text,
                    'growthOpportunities': _growthOpportunitiesController.text,
                    'salary': {
                      'min': double.parse(_salaryMinController.text),
                      'max': double.parse(_salaryMaxController.text),
                    },
                    'applicationInstructions': _applicationInstructionsController.text,
                  },
                  'requirements': selectedRequirements,
                  'jobType': selectedJobType,
                  'jobLocation': selectedJobLocation,
                  'jobLocationDetails': {
                    'address': _addressController.text,
                    'city': _cityController.text,
                    'state': _stateController.text,
                    'country': _countryController.text,
                  },
                  'employmentType': selectedEmploymentType,
                  'experienceLevel': selectedExperienceLevel,
                  'deadline': deadline?.toIso8601String(),
                  'accessibilityFeatures': {
                    'workplaceAccommodations': selectedWorkplaceAccommodations,
                    'communicationSupport': selectedCommunicationSupport,
                    'disabilityFriendliness': selectedDisabilityFriendliness,
                  },
                  'inclusivityStatement': _inclusivityStatementController.text,
                  'specialNeeds': {
                    'personalAssistanceAvailable': personalAssistanceAvailable,
                    'specialEquipmentProvided': specialEquipmentProvided,
                    'additionalSupportDetails': _additionalSupportDetailsController.text,
                  },
                  'disabilityTypes': {
                    'supportedDisabilities': selectedSupportedDisabilities,
                  },
                  'inclusiveHiringPractices': {
                    'blindRecruitment': blindRecruitment,
                    'alternativeInterviewFormats': selectedAlternativeInterviewFormats,
                  },
                },
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
        Text(
          label,
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildSwitchListTile(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Deadline',
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deadline == null
                      ? 'Select Deadline'
                      : '${deadline!.day}/${deadline!.month}/${deadline!.year}',
                ),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roleOverviewController.dispose();
    _contentController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _companyOverviewController.dispose();
    _growthOpportunitiesController.dispose();
    _applicationInstructionsController.dispose();
    _additionalSupportDetailsController.dispose();
    _inclusivityStatementController.dispose();
    super.dispose();
  }
}