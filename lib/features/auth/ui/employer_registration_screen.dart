import 'package:android/core/utils/snackBarUtils.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../employer_registration_bloc/employer_registration_bloc.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // For company and personal details
  final _otpFormKey = GlobalKey<FormState>(); // For OTP only
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController industryTypeController = TextEditingController();
  final TextEditingController employerStrengthsController =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController officialAddressController =
      TextEditingController();
  final TextEditingController verificationDocTypeController =
      TextEditingController();

  final List<String> industryTypes = [
    'Tech',
    'Finance',
    'Healthcare',
    'Education',
    'Other'
  ]; // Customize as needed
  final List<String> employerStrengthOptions = [
    '1-5',
    '6-10',
    '11-15',
    '16-20',
    '21-25',
    '26-30',
    '31-35',
    '36-40',
    '41-45',
    '46-50',
    'More than 50'
  ];
  final List<String> verificationDocTypes = [
    'Business Registration',
    'GST Certificate',
    'License',
    'PAN Card',
    'Trademark Certificate',
    'Share Stock Certificate',
    'Other'
  ];

  Map<String, Map<String, String>> documentUrls = {
    'logo': {'url': '', 'publicId': ''},
    'profile': {'url': '', 'publicId': ''},
    'verification': {'url': '', 'publicId': ''},
  };

  int step = 1;
  String currentUploadingDocType = '';

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => EmployerRegistrationBloc(),
      child: BlocConsumer<EmployerRegistrationBloc, EmployerRegistrationState>(
        listener: (context, state) {
          print("Listener received state: $state");
          if (state is RegistrationFailure) {
            SnackBarUtils.showRedSnackBar(state.error, context);
          } else if (state is CompanyExists) {
            SnackBarUtils.showGreenSnackBar(state.message, context);
          } else if (state is CompanyNotFound) {
            print("Moving to Step 2");
            setState(() => step = 2);
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
                    child: LoginScreen(userType: "employer"),
                  ),
                ));
          }
        },
        builder: (context, state) {
          print("Builder received state: $state");
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
                          child: Icon(Icons.business,
                              size: screenSize.width * 0.125,
                              color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        step == 1
                            ? 'Check Your Company'
                            : step == 2
                                ? 'Company Details'
                                : step == 3
                                    ? 'Personal Details'
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
                            ? 'Enter company details to start'
                            : step == 2
                                ? 'Provide company details and upload documents'
                                : step == 3
                                    ? 'Enter your personal details'
                                    : 'Verify your email to complete registration',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                              fontSize: screenSize.width * 0.04,
                            ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      if (step == 1)
                        _buildCompanyCheckStep(context, screenSize),
                      if (step == 2)
                        _buildCompanyDetailsStep(context, screenSize),
                      if (step == 3)
                        _buildPersonalDetailsStep(context, screenSize),
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
          _buildStepIndicator(1, "Check", step >= 1),
          _buildStepConnector(step > 1),
          _buildStepIndicator(2, "Company", step >= 2),
          _buildStepConnector(step > 2),
          _buildStepIndicator(3, "Personal", step >= 3),
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
              child: BlocBuilder<EmployerRegistrationBloc,
                  EmployerRegistrationState>(
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

  void saveDataForCurrentStep() {
    switch (step) {
      case 1:
        // Data already saved in controllers
        break;
      case 2:
        // Save company details
        _formKey.currentState?.save();
        break;
      case 3:
        // Save personal details
        _formKey.currentState?.save();
        break;
      case 4:
        // OTP verification
        _otpFormKey.currentState?.save();
        break;
    }
  }

  Widget _buildCompanyCheckStep(BuildContext context, Size screenSize) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Company Email',
              prefixIcon: Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter company email' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: companyNameController,
            decoration: InputDecoration(
              labelText: 'Company Name',
              prefixIcon: Icon(Icons.business),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter company name' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_formKey.currentState!.validate()) {
                saveDataForCurrentStep();
                BlocProvider.of<EmployerRegistrationBloc>(context).add(
                  CheckCompanyEvent(
                    email: emailController.text,
                    companyName: companyNameController.text,
                  ),
                );
              }
            },
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailsStep(BuildContext context, Size screenSize) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: websiteController,
            decoration: InputDecoration(
              labelText: 'Website',
              prefixIcon: Icon(Icons.web),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter website' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: aboutController,
            decoration: InputDecoration(
              labelText: 'About Company',
              prefixIcon: Icon(Icons.info),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter about company' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          DropdownButtonFormField<String>(
            value: industryTypeController.text.isEmpty
                ? null
                : industryTypeController.text,
            decoration: InputDecoration(
              labelText: 'Industry Type',
              prefixIcon: Icon(Icons.category),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: industryTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => industryTypeController.text = value ?? '',
            validator: (value) =>
                value == null ? 'Please select industry type' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          DropdownButtonFormField<String>(
            value: employerStrengthsController.text.isEmpty
                ? null
                : employerStrengthsController.text,
            decoration: InputDecoration(
              labelText: 'Employer Strengths',
              prefixIcon: Icon(Icons.group),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: employerStrengthOptions.map((String strength) {
              return DropdownMenuItem<String>(
                  value: strength, child: Text(strength));
            }).toList(),
            onChanged: (value) =>
                employerStrengthsController.text = value ?? '',
            validator: (value) =>
                value == null ? 'Please select employer strength' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: officialAddressController,
            decoration: InputDecoration(
              labelText: 'Official Address',
              prefixIcon: Icon(Icons.location_on),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter official address' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: countryController,
            decoration: InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(Icons.public),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter country' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: stateController,
            decoration: InputDecoration(
              labelText: 'State',
              prefixIcon: Icon(Icons.map),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter state' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter city' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: pincodeController,
            decoration: InputDecoration(
              labelText: 'Pincode',
              prefixIcon: Icon(Icons.pin_drop),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter pincode' : null,
          ),

          SizedBox(height: screenSize.height * 0.04),
          Text(
            "Company Documents",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),

          // Enhanced document upload section
          _buildDocumentUploadCard(
              context,
              'Company Logo',
              'Upload a high-quality logo (PNG or JPG)',
              'logo',
              Icons.image_outlined,
              screenSize),
          _buildDocumentUploadCard(
              context,
              'Company Profile',
              'Upload company Employer Profile document (PDF preferred)',
              'profile',
              Icons.business_outlined,
              screenSize),

          DropdownButtonFormField<String>(
            value: verificationDocTypeController.text.isEmpty
                ? null
                : verificationDocTypeController.text,
            decoration: InputDecoration(
              labelText: 'Verification Document Type',
              prefixIcon: Icon(Icons.description_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: verificationDocTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) =>
                verificationDocTypeController.text = value ?? '',
            validator: (value) =>
                value == null ? 'Please select document type' : null,
          ),

          SizedBox(height: screenSize.height * 0.02),

          _buildDocumentUploadCard(
              context,
              'Verification Document',
              'Upload document for verification',
              'verification',
              Icons.verified_outlined,
              screenSize),
          SizedBox(height: screenSize.height * 0.04),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_formKey.currentState!.validate()) {
                saveDataForCurrentStep();
                setState(() => step = 3);
              }
            },
            documentUrls.values.every((doc) => doc['url']!.isNotEmpty),
          ),

          SizedBox(height: screenSize.height * 0.02),
          if (!documentUrls.values.every((doc) => doc['url']!.isNotEmpty))
            Text(
              'Please upload all required documents to proceed',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(BuildContext context, String label,
      String description, String type, IconData icon, Size screenSize) {
    bool isUploaded = documentUrls[type]!['url']!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300),
        //    color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded ? Colors.green.shade100 : Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.check : icon,
            color: isUploaded ? Colors.green.shade700 : Colors.blue.shade700,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            //    color: Colors.black87,
          ),
        ),
        subtitle: Text(
          isUploaded ? 'Document uploaded successfully' : description,
          style: TextStyle(
            color: isUploaded ? Colors.green.shade700 : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        trailing: isUploaded
            ? IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue),
                onPressed: () {
                  // Allow replacing the uploaded document
                  setState(() {
                    documentUrls[type] = {'url': '', 'publicId': ''};
                  });
                },
              )
            : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    currentUploadingDocType = type;
                  });

                  FilePickerResult? result;
                  if (type == 'Employer Profile') {
                    result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpeg'],
                    );
                  } else {
                    // For logo and verification docs, use image type instead
                    result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                  }

                  if (result != null &&
                      result.files.isNotEmpty &&
                      result.files.single.path != null) {
                    // Show loading indicator before starting upload
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LoadingAnimationWidget.hexagonDots(
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Uploading $label...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    // Add upload event
                    BlocProvider.of<EmployerRegistrationBloc>(context).add(
                      UploadDocumentEvent(filePath: result.files.single.path!),
                    );

                    // Close dialog after a brief delay
                    Future.delayed(Duration(milliseconds: 500), () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text('Upload'),
              ),
      ),
    );
  }

  Widget _buildPersonalDetailsStep(BuildContext context, Size screenSize) {
    return Form(
      key: _formKey,
      child: Column(
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
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your password' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildNavigationButtons(
            context,
            screenSize,
            () {
              if (_formKey.currentState!.validate()) {
                saveDataForCurrentStep();
                BlocProvider.of<EmployerRegistrationBloc>(context).add(
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
                saveDataForCurrentStep();
                BlocProvider.of<EmployerRegistrationBloc>(context).add(
                  VerifyOtpEvent(
                      email: emailController.text, otp: otpController.text),
                );
              }
            },
            true,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextButton(
            onPressed: () {
              BlocProvider.of<EmployerRegistrationBloc>(context)
                  .add(SendOtpEvent(email: emailController.text));
            },
            child: Text('Resend OTP', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _submitRegistration(BuildContext context) {
    final companyData = {
      'email': emailController.text,
      'companyName': companyNameController.text,
      'website': websiteController.text,
      'about': aboutController.text,
      'industryType': industryTypeController.text,
      'employerStrengths': employerStrengthsController.text,
      'location': {
        'country': countryController.text,
        'state': stateController.text,
        'city': cityController.text,
        'pincode': pincodeController.text,
      },
      'officialAddress': officialAddressController.text,
      'billingDetails': {
        'GSTNo': '',
        'PANNo': '',
        'MSME': ''
      }, // Still optional
      'verificationDocument': {'type': verificationDocTypeController.text},
      'socialAccount': {
        'linkedin': '',
        'instagram': '',
        'twitter': ''
      }, // Still optional
    };
    final employerData = {
      'fullName': fullNameController.text,
      'designation': 'Admin',
      'password': passwordController.text,
      'phoneNumber': phoneController.text,
      'email': emailController.text,
    };
    BlocProvider.of<EmployerRegistrationBloc>(context).add(
      SubmitRegistrationEvent(
        companyData: companyData,
        employerData: employerData,
        documentUrls: documentUrls,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    companyNameController.dispose();
    websiteController.dispose();
    aboutController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    industryTypeController.dispose();
    employerStrengthsController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    officialAddressController.dispose();
    verificationDocTypeController.dispose();
    super.dispose();
  }
}
