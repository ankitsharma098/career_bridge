import 'package:android/features/auth/ui/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../registration_bloc/registration_bloc.dart';

class RegistrationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const RegistrationScreen({super.key, required this.isDarkMode, required this.onThemeToggle});

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

  Map<String, Map<String, String>> documentUrls = {
    'logo': {'url': '', 'publicId': ''},
    'verification': {'url': '', 'publicId': ''},
    'profile': {'url': '', 'publicId': ''},
  };
  String? verificationToken;
  int step = 1;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => RegistrationBloc(),
      child: BlocConsumer<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          print("Listener received state: $state");
          if (state is RegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is CompanyExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CompanyNotFound) {
            print("Moving to Step 2");
            setState(() => step = 2);
          } else if (state is DocumentUploaded) {
            setState(() {
              if (documentUrls['logo']!['url']!.isEmpty) {
                documentUrls['logo'] = {'url': state.url, 'publicId': state.publicId};
              } else if (documentUrls['verification']!['url']!.isEmpty) {
                documentUrls['verification'] = {'url': state.url, 'publicId': state.publicId};
              } else if (documentUrls['profile']!['url']!.isEmpty) {
                documentUrls['profile'] = {'url': state.url, 'publicId': state.publicId};
              }
            });
          } else if (state is OtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP sent to ${emailController.text}')),
            );
          } else if (state is OtpVerified) {
            setState(() {
              verificationToken = state.token;
            });
            // Auto-submit after OTP verification
            _submitRegistration(context);
          } else if (state is RegistrationSuccess) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(isDarkMode: widget.isDarkMode, onThemeToggle:widget.onThemeToggle,userType: "employer"),));
          }
        },
        builder: (context, state) {
          print("Builder received state: $state");
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.1),
                      Center(
                        child: Container(
                          height: screenSize.width * 0.25,
                          width: screenSize.width * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.business, size: screenSize.width * 0.125, color: Colors.blue),
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
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
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
                      if (step == 1) _buildCompanyCheckStep(context, screenSize),
                      if (step == 2) _buildCompanyDetailsStep(context, screenSize),
                      if (step == 3) _buildPersonalDetailsStep(context, screenSize),
                      if (step == 4) _buildOtpVerificationStep(context, screenSize),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter company email' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: companyNameController,
            decoration: InputDecoration(
              labelText: 'Company Name',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter company name' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            width: double.infinity,
            height: screenSize.height * 0.07,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  BlocProvider.of<RegistrationBloc>(context).add(
                    CheckCompanyEvent(
                      email: emailController.text,
                      companyName: companyNameController.text,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (context, state) {
                  if (state is RegistrationLoading) {
                    return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 20);
                  }
                  return Text('Check Company', style: TextStyle(color: Colors.white));
                },
              ),
            ),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter website' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: aboutController,
            decoration: InputDecoration(
              labelText: 'About Company',
              prefixIcon: Icon(Icons.info),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter about company' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildUploadButton(context, 'Company Logo', 'logo', screenSize),
          _buildUploadButton(context, 'Verification Document', 'verification', screenSize),
          _buildUploadButton(context, 'Company Profile', 'profile', screenSize),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            width: double.infinity,
            height: screenSize.height * 0.07,
            child: ElevatedButton(
              onPressed: documentUrls.values.every((doc) => doc['url']!.isNotEmpty)
                  ? () {
                if (_formKey.currentState!.validate()) {
                  setState(() => step = 3);
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: documentUrls.values.every((doc) => doc['url']!.isNotEmpty) ? Colors.blue : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, String label, String type, Size screenSize) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: documentUrls[type]!['url']!.isNotEmpty
              ? null
              : () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null) {
              BlocProvider.of<RegistrationBloc>(context).add(
                UploadDocumentEvent(filePath: result.files.single.path!),
              );
            }
          },
          child: Text(documentUrls[type]!['url']!.isEmpty ? 'Upload $label' : '$label Uploaded'),
          style: ElevatedButton.styleFrom(
            backgroundColor: documentUrls[type]!['url']!.isEmpty ? Colors.blue : Colors.grey,
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
      ],
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            width: double.infinity,
            height: screenSize.height * 0.07,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  BlocProvider.of<RegistrationBloc>(context).add(
                    SendOtpEvent(email: emailController.text),
                  );
                  setState(() => step = 4);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Next', style: TextStyle(color: Colors.white)),
            ),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter OTP' : null,
          ),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            width: double.infinity,
            height: screenSize.height * 0.07,
            child: ElevatedButton(
              onPressed: () {
                if (_otpFormKey.currentState!.validate()) {
                  BlocProvider.of<RegistrationBloc>(context).add(
                    VerifyOtpEvent(email: emailController.text, otp: otpController.text),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (context, state) {
                  if (state is RegistrationLoading) {
                    return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 20);
                  }
                  return Text('Verify & Complete', style: TextStyle(color: Colors.white));
                },
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextButton(
            onPressed: () {
              BlocProvider.of<RegistrationBloc>(context).add(SendOtpEvent(email: emailController.text));
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
      'industryType': 'Tech',
      'employerStrengths': '1-5',
      'location': {'country': 'Country', 'state': 'State', 'city': 'City', 'pincode': '123456'},
      'officialAddress': 'Address',
      'billingDetails': {'GSTNo': '', 'PANNo': '123', 'MSME': 'Yes'},
      'verificationDocument': {'type': 'Business Registration'},
      'socialAccount': {'linkedin': '', 'instagram': '', 'twitter': ''},
    };
    final employerData = {
      'fullName': fullNameController.text,
      'designation': 'Admin',
      'password': passwordController.text,
      'phoneNumber': phoneController.text,
      'email': emailController.text,
    };
    BlocProvider.of<RegistrationBloc>(context).add(
      SubmitRegistrationEvent(
        companyData: companyData,
        employerData: employerData,
        documentUrls: documentUrls,
        verificationToken: verificationToken!,
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
    super.dispose();
  }
}