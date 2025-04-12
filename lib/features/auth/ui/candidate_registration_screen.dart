import 'package:android/core/utils/snackBarUtils.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../candidate_registration_bloc/candidate_registration_bloc.dart';

class CandidateRegistrationScreen extends StatefulWidget {
  const CandidateRegistrationScreen({super.key});

  @override
  _CandidateRegistrationScreenState createState() =>
      _CandidateRegistrationScreenState();
}

class _CandidateRegistrationScreenState
    extends State<CandidateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  // Personal Info
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedGender = 'Male';

  // Disability Details
  final TextEditingController disabilityTypeController =
      TextEditingController();
  final TextEditingController disabilityPercentageController =
      TextEditingController();
  final TextEditingController certificateNumberController =
      TextEditingController();
  String selectedCommunicationMethod = 'Text-based Communication';
  List<String> selectedAccommodations = [];
  List<String> selectedAssistiveTech = [];

  // Skills
  final List<String> selectedSkills = [];

  // Job Preferences
  final List<String> selectedIndustries = [];
  final List<String> selectedRoles = [];
  final List<String> selectedLocations = [];
  final TextEditingController preferredSalaryController =
      TextEditingController();
  String selectedWorkMode = 'Flexible';
  List<String> selectedEmploymentTypes = ['Full-time'];
  String selectedExperienceLevel = 'Freshers';

  // Authentication
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Document URLs
  Map<String, Map<String, String>> documentUrls = {
    'certificate': {'url': '', 'publicId': ''},
  };

  // Options Lists
  final List<String> genderOptions = ['Male', 'Female', 'Transgender'];
  final List<String> disabilityTypes = [
    'Visual',
    'Hearing',
    'Physical',
    'Cognitive',
    'Other'
  ];
  final List<String> communicationMethodOptions = [
    'Text-based Communication',
    'Visual Communication',
    'Sign Language Support',
    'Closed Captioning',
    'Screen Reader Friendly'
  ];
  final List<String> accommodationOptions = [
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
  final List<String> assistiveTechOptions = [
    'Screen Reader',
    'Speech Recognition',
    'Alternative Keyboard',
    'Alternative Mouse',
    'Other'
  ];
  final List<String> skillsList = [
    'Problem Solving',
    'Data Analysis',
    'Web Development',
    'Graphic Design',
    'Content Writing',
    'Digital Marketing'
  ];
  final List<String> industryOptions = [
    'Technology',
    'Healthcare',
    'Education',
    'Finance',
    'Hospitality',
    'Government',
    'Non-profit'
  ];
  final List<String> roleOptions = [
    'Software Developer',
    'Data Analyst',
    'Customer Support',
    'Project Manager',
    'Marketing Specialist',
    'HR Specialist',
    'Financial Analyst',
    'Designer',
  ];
  final List<String> locationOptions = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Noida',
  ];
  final List<String> workModeOptions = [
    'Remote',
    'Onsite',
    'Hybrid',
    'Flexible'
  ];
  final List<String> employmentTypeOptions = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship'
  ];
  final List<String> experienceLevelOptions = [
    'Freshers',
    'Intermediate',
    'Professional'
  ];
  TextEditingController industryController = TextEditingController();
  TextEditingController skillController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController locationController = TextEditingController();

// Add these lists to store custom entries
  List<String> tempIndustries = [];
  List<String> tempSkills = [];
  List<String> tempRoles = [];
  List<String> tempLocations = [];

  int step = 1;
  String currentUploadingDocType = '';

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => CandidateRegistrationBloc(),
      child:
          BlocConsumer<CandidateRegistrationBloc, CandidateRegistrationState>(
        listener: (context, state) {
          if (state is RegistrationFailure) {
            SnackBarUtils.showRedSnackBar(state.error, context);
          } else if (state is EmailExists) {
            SnackBarUtils.showRedSnackBar("Email already registered", context);
          } else if (state is DocumentUploaded) {
            setState(() {
              documentUrls[currentUploadingDocType] = {
                'url': state.url,
                'publicId': state.publicId
              };
            });
          } else if (state is OtpSent) {
            SnackBarUtils.showGreenSnackBar(
                'OTP sent to ${emailController.text}', context);
          } else if (state is OtpVerified) {
            _submitRegistration(context);
          } else if (state is RegistrationSuccess) {
            SnackBarUtils.showGreenSnackBar(
                'Registration Successfully, Please login', context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => LoginBloc(),
                    child: LoginScreen(userType: "candidate"),
                  ),
                ));
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.05),
                      _buildStepper(screenSize),
                      Center(
                        child: Container(
                          height: screenSize.width * 0.25,
                          width: screenSize.width * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person,
                              size: screenSize.width * 0.125,
                              color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        step == 1
                            ? 'Personal Information'
                            : step == 2
                                ? 'Disability Details'
                                : step == 3
                                    ? 'Skills & Preferences'
                                    : 'Verify OTP',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: screenSize.width * 0.07,
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        step == 1
                            ? 'Enter your personal information'
                            : step == 2
                                ? 'Provide details about your disability'
                                : step == 3
                                    ? 'Select your skills and job preferences'
                                    : 'Verify your email to complete registration',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                              fontSize: screenSize.width * 0.04,
                            ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      if (step == 1)
                        _buildPersonalInfoStep(context, screenSize),
                      if (step == 2)
                        _buildDisabilityDetailsStep(context, screenSize),
                      if (step == 3)
                        _buildSkillsPreferencesStep(context, screenSize),
                      if (step == 4)
                        _buildOtpVerificationStep(context, screenSize),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepper(Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(1, "Personal", step >= 1),
          _buildStepConnector(step > 1),
          _buildStepIndicator(2, "Disability", step >= 2),
          _buildStepConnector(step > 2),
          _buildStepIndicator(3, "Skills", step >= 3),
          _buildStepConnector(step > 3),
          _buildStepIndicator(4, "Verify", step >= 4),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label, bool isActive) {
    return InkWell(
      onTap: () {
        // Only allow going back to steps we've already visited
        if (stepNumber < step) {
          setState(() => step = stepNumber);
        }
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 30,
      height: 2,
      color: isActive ? Colors.blue : Colors.grey.shade300,
      margin: EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, Size screenSize,
      VoidCallback onNext, bool isNextEnabled) {
    return Row(
      children: [
        if (step > 1)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                height: screenSize.height * 0.07,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => step--);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Back', style: TextStyle(color: Colors.blue)),
                ),
              ),
            ),
          ),
        Expanded(
          child: SizedBox(
            height: screenSize.height * 0.07,
            child: ElevatedButton(
              onPressed: isNextEnabled ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isNextEnabled ? Colors.blue : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: BlocBuilder<CandidateRegistrationBloc,
                  CandidateRegistrationState>(
                builder: (context, state) {
                  if (state is RegistrationLoading) {
                    return LoadingAnimationWidget.hexagonDots(
                        color: Colors.white, size: 20);
                  }
                  return Text(step == 4 ? 'Verify & Complete' : 'Next',
                      style: TextStyle(
                          color: isNextEnabled
                              ? Colors.white
                              : Colors.grey.shade700));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep(BuildContext context, Size screenSize) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your full name' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your email' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your phone number' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'Address (Optional)',
              prefixIcon: Icon(Icons.home),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            "Gender",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: genderOptions.map((gender) {
              return ChoiceChip(
                label: Text(gender),
                selected: selectedGender == gender,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedGender = gender;
                    });
                  }
                },
                // backgroundColor: Colors.grey.shade200,
                // selectedColor: Colors.blue.shade100,
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter a password' : null,
          ),
          SizedBox(height: screenSize.height * 0.04),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_formKey.currentState!.validate()) {
                setState(() => step = 2);
              }
            },
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildDisabilityDetailsStep(BuildContext context, Size screenSize) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: disabilityTypeController.text.isEmpty
                ? null
                : disabilityTypeController.text,
            decoration: InputDecoration(
              labelText: 'Disability Type',
              prefixIcon: Icon(Icons.accessible),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: disabilityTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => disabilityTypeController.text = value ?? '',
            validator: (value) =>
                value == null ? 'Please select disability type' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: disabilityPercentageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Disability Percentage',
              prefixIcon: Icon(Icons.percent),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter disability percentage' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: certificateNumberController,
            decoration: InputDecoration(
              labelText: 'Certificate Number',
              prefixIcon: Icon(Icons.badge),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter certificate number' : null,
          ),
          SizedBox(height: screenSize.height * 0.04),
          _buildDocumentUploadCard(
              context,
              'Disability Certificate',
              'Upload your disability certificate (PDF or image)',
              'certificate',
              Icons.file_copy_outlined,
              screenSize),
          SizedBox(height: screenSize.height * 0.04),
          Text(
            "Preferred Communication Method",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: communicationMethodOptions.map((method) {
              return ChoiceChip(
                label: Text(method),
                selected: selectedCommunicationMethod == method,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedCommunicationMethod = method;
                    });
                  }
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.03),
          Text(
            "Accommodations Needed",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: accommodationOptions.map((accommodation) {
              return FilterChip(
                label: Text(accommodation),
                selected: selectedAccommodations.contains(accommodation),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedAccommodations.add(accommodation);
                    } else {
                      selectedAccommodations.remove(accommodation);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.03),
          Text(
            "Assistive Technology Used",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: assistiveTechOptions.map((tech) {
              return FilterChip(
                label: Text(tech),
                selected: selectedAssistiveTech.contains(tech),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedAssistiveTech.add(tech);
                    } else {
                      selectedAssistiveTech.remove(tech);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.04),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_formKey.currentState!.validate() &&
                  documentUrls['certificate']!['url']!.isNotEmpty) {
                setState(() => step = 3);
              } else {
                SnackBarUtils.showRedSnackBar(
                    "Please upload your disability certificate", context);
              }
            },
            documentUrls['certificate']!['url']!.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsPreferencesStep(BuildContext context, Size screenSize) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Skills",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: skillController,
            decoration: InputDecoration(
              hintText: 'Enter a skill (e.g., Flutter, Java)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final skill = skillController.text.trim();
                  if (skill.isNotEmpty &&
                      !selectedSkills.contains(skill) &&
                      !tempSkills.contains(skill)) {
                    setState(() {
                      tempSkills.add(skill);
                      selectedSkills.add(skill);
                      skillController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: [...skillsList, ...tempSkills].map((skill) {
              return FilterChip(
                label: Text(skill),
                selected: selectedSkills.contains(skill),
                onSelected: (selected) {
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
          SizedBox(height: screenSize.height * 0.03),
          Text(
            "Job Preferences",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Preferred Industries",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          TextField(
            controller: industryController,
            decoration: InputDecoration(
              hintText: 'Enter a custom industry',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final industry = industryController.text.trim();
                  if (industry.isNotEmpty &&
                      !selectedIndustries.contains(industry) &&
                      !tempIndustries.contains(industry)) {
                    setState(() {
                      tempIndustries.add(industry);
                      selectedIndustries.add(industry);
                      industryController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: [...industryOptions, ...tempIndustries].map((industry) {
              return FilterChip(
                label: Text(industry),
                selected: selectedIndustries.contains(industry),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedIndustries.add(industry);
                    } else {
                      selectedIndustries.remove(industry);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            "Preferred Roles",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          TextField(
            controller: roleController,
            decoration: InputDecoration(
              hintText: 'Enter a custom role',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final role = roleController.text.trim();
                  if (role.isNotEmpty &&
                      !selectedRoles.contains(role) &&
                      !tempRoles.contains(role)) {
                    setState(() {
                      tempRoles.add(role);
                      selectedRoles.add(role);
                      roleController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: [...roleOptions, ...tempRoles].map((role) {
              return FilterChip(
                label: Text(role),
                selected: selectedRoles.contains(role),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedRoles.add(role);
                    } else {
                      selectedRoles.remove(role);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            "Preferred Locations",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              hintText: 'Enter a custom location',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final location = locationController.text.trim();
                  if (location.isNotEmpty &&
                      !selectedLocations.contains(location) &&
                      !tempLocations.contains(location)) {
                    setState(() {
                      tempLocations.add(location);
                      selectedLocations.add(location);
                      locationController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: [...locationOptions, ...tempLocations].map((location) {
              return FilterChip(
                label: Text(location),
                selected: selectedLocations.contains(location),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedLocations.add(location);
                    } else {
                      selectedLocations.remove(location);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: preferredSalaryController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Preferred Salary (in ₹)',
              prefixIcon: Icon(Icons.currency_rupee),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter preferred salary' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            "Preferred Work Mode",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: workModeOptions.map((mode) {
              return ChoiceChip(
                label: Text(mode),
                selected: selectedWorkMode == mode,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedWorkMode = mode;
                    });
                  }
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            "Employment Type",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: employmentTypeOptions.map((type) {
              return FilterChip(
                label: Text(type),
                selected: selectedEmploymentTypes.contains(type),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedEmploymentTypes.add(type);
                    } else {
                      if (selectedEmploymentTypes.length > 1) {
                        selectedEmploymentTypes.remove(type);
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            "Experience Level",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: 10,
            children: experienceLevelOptions.map((level) {
              return ChoiceChip(
                label: Text(level),
                selected: selectedExperienceLevel == level,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedExperienceLevel = level;
                    });
                  }
                },
              );
            }).toList(),
          ),
          SizedBox(height: screenSize.height * 0.04),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_formKey.currentState!.validate()) {
                if (selectedSkills.isEmpty) {
                  SnackBarUtils.showRedSnackBar(
                      "Please select at least one skill", context);
                  return;
                }
                if (selectedIndustries.isEmpty) {
                  SnackBarUtils.showRedSnackBar(
                      "Please select at least one industry", context);
                  return;
                }
                if (selectedRoles.isEmpty) {
                  SnackBarUtils.showRedSnackBar(
                      "Please select at least one role", context);
                  return;
                }
                if (selectedLocations.isEmpty) {
                  SnackBarUtils.showRedSnackBar(
                      "Please select at least one location", context);
                  return;
                }

                BlocProvider.of<CandidateRegistrationBloc>(context).add(
                  SendOtpEvent(email: emailController.text),
                );
                setState(() => step = 4);
              }
            },
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationStep(BuildContext context, Size screenSize) {
    return Form(
      key: _otpFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: otpController,
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              prefixIcon: Icon(Icons.lock),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter OTP' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_otpFormKey.currentState!.validate()) {
                BlocProvider.of<CandidateRegistrationBloc>(context).add(
                  VerifyOtpEvent(
                      email: emailController.text, otp: otpController.text),
                );
              }
            },
            true,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't receive the OTP?"),
              TextButton(
                onPressed: () {
                  BlocProvider.of<CandidateRegistrationBloc>(context).add(
                    SendOtpEvent(email: emailController.text),
                  );
                },
                child: Text("Resend"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(BuildContext context, String title,
      String subtitle, String docType, IconData icon, Size screenSize) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
            SizedBox(height: 16),
            if (documentUrls[docType]!['url']!.isEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text('Select File'),
                  onPressed: () => _uploadDocument(context, docType),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Document uploaded successfully',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            documentUrls[docType] = {'url': '', 'publicId': ''};
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text('Replace File'),
                      onPressed: () => _uploadDocument(context, docType),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadDocument(BuildContext context, String docType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          currentUploadingDocType = docType;
        });

        BlocProvider.of<CandidateRegistrationBloc>(context).add(
          UploadDocumentEvent(
            file: result.files.first,
            docType: docType,
          ),
        );
      }
    } catch (e) {
      SnackBarUtils.showRedSnackBar("Error picking file: $e", context);
    }
  }

  void _submitRegistration(BuildContext context) {
    final personalInfo = {
      'fullName': fullNameController.text,
      'email': emailController.text,
      'phoneNumber': phoneController.text,
      'address': addressController.text,
      'gender': selectedGender,
    };
    final disabilityDetails = {
      'type': disabilityTypeController.text,
      'percentage': disabilityPercentageController.text,
      'certificateNumber': certificateNumberController.text,
      'preferredCommunicationMethod': selectedCommunicationMethod,
      'accommodationsNeeded': selectedAccommodations,
      'assistiveTechnology': selectedAssistiveTech,
      'certificateDoc': documentUrls['certificate']!['url'],
      'publicId': documentUrls['certificate']!['publicId'],
    };
    final skills = selectedSkills;
    final jobPreferences = {
      'industries': selectedIndustries,
      'roles': selectedRoles,
      'location': selectedLocations,
      'preferredSalary': preferredSalaryController.text,
      'workMode': selectedWorkMode,
      'employmentTypes': selectedEmploymentTypes,
      'experienceLevel': selectedExperienceLevel,
    };

    final auth = {
      'password': passwordController.text,
    };

    print("$personalInfo $disabilityDetails, $skills, $jobPreferences, $auth");
    BlocProvider.of<CandidateRegistrationBloc>(context).add(
        RegisterCandidateEvent(
            personalInfo, disabilityDetails, skills, jobPreferences, auth));
  }
}
