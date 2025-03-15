import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../Apply Job Bloc/apply_job_bloc.dart';

class ApplyJobScreen extends StatefulWidget {
  final String jobId;

  const ApplyJobScreen({super.key, required this.jobId});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isFresher = true;
  List<Map<String, TextEditingController>> experiences = [];
  Map<String, String> documentUrls = {'resume': ''};

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    for (var exp in experiences) {
      exp['designation']!.dispose();
      exp['company']!.dispose();
      exp['duration']!.dispose();
      exp['description']!.dispose();
    }
    super.dispose();
  }

  void _addExperience() {
    setState(() {
      experiences.add({
        'designation': TextEditingController(),
        'company': TextEditingController(),
        'duration': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeExperience(int index) {
    setState(() {
      experiences[index].forEach((key, controller) => controller.dispose());
      experiences.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;

    return BlocProvider(
      create: (context) => ApplyJobBloc(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            'Apply for Job',
          ),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(
          //     bottom: Radius.circular(20),
          //   ),
          // ),
        ),
        body: BlocConsumer<ApplyJobBloc, ApplyJobState>(
          listener: (context, state) {
            if (state is ApplicationsError) {
              SnackBarUtils.showRedSnackBar(state.error, context);
            } else if (state is ApplicationsSuccess) {
              SnackBarUtils.showGreenSnackBar(state.message, context);
              Navigator.pop(context);
            } else if (state is DocumentUploaded) {
              setState(() {
                documentUrls['resume'] = state.url;
              });
            }
          },
          builder: (context, state) {
            if (state is ApplicationsLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.discreteCircle(
                      color: primaryColor,
                      size: 50,
                      secondRingColor: Colors.amber,
                      thirdRingColor: Colors.green,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Processing your application...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                    )
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? null
                    : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.withOpacity(0.05),
                    Colors.purple.withOpacity(0.03),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Apply with confidence', Icons.cases_outlined),
                    SizedBox(height: 5),
                    Text(
                      'Complete the form below to submit your application',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.025),
                    _buildFresherToggle(context, screenSize),
                    SizedBox(height: screenSize.height * 0.02),
                    if (!isFresher) _buildExperienceSection(context, screenSize),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildContactInfoSection(context, screenSize),
                    SizedBox(height: screenSize.height * 0.025),
                    _buildDocumentUploadCard(
                      context,
                      'Resume',
                      'Upload your resume in PDF format',
                      'resume',
                      Icons.description,
                      screenSize,
                    ),
                    SizedBox(height: screenSize.height * 0.035),
                    _buildSubmitButton(context, screenSize),
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFresherToggle(BuildContext context, Size screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experience Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                isFresher ? 'Fresher' : 'Experienced',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: isFresher,
              onChanged: (value) {
                setState(() {
                  isFresher = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.3),
              inactiveThumbColor: isDarkMode ? Colors.grey[400] : Colors.grey[300],
              inactiveTrackColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(BuildContext context, Size screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Professional Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _addExperience,
                icon: Icon(Icons.add_circle, color: primaryColor),
                label: Text(
                  'Add',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: primaryColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          if (experiences.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 48,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Add your work experience',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ...experiences.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, TextEditingController> exp = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Experience ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                        onPressed: () => _removeExperience(index),
                        tooltip: 'Remove Experience',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildTextField(context, exp['designation']!, 'Designation', screenSize, icon: Icons.person),
                  _buildTextField(context, exp['company']!, 'Company', screenSize, icon: Icons.business),
                  _buildTextField(context, exp['duration']!, 'Duration', screenSize, icon: Icons.calendar_today, hintText: 'e.g., Jan 2020 - Mar 2022'),
                  _buildTextField(context, exp['description']!, 'Description', screenSize, icon: Icons.description, maxLines: 3, hintText: 'Describe your responsibilities and achievements'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(BuildContext context, Size screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          _buildTextField(context, emailController, 'Email', screenSize, icon: Icons.email, hintText: 'your.email@example.com'),
          _buildTextField(context, phoneController, 'Phone', screenSize, icon: Icons.phone, hintText: '+1 123 456 7890'),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(
      BuildContext context,
      String label,
      String description,
      String type,
      IconData icon,
      Size screenSize,
      ) {
    bool isUploaded = documentUrls[type]!.isNotEmpty;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: isUploaded
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withOpacity(0.1)
                  : primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isUploaded ? Icons.check_circle : icon,
                color: isUploaded ? Colors.green : primaryColor,
                size: 30,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isUploaded ? 'Document uploaded successfully' : description,
                  style: TextStyle(
                    color: isUploaded
                        ? Colors.green
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 14,
                  ),
                ),
                if (isUploaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.file_present, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Resume.pdf',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          isUploaded
              ? TextButton.icon(
            onPressed: () {
              setState(() {
                documentUrls[type] = '';
              });
            },
            icon: Icon(Icons.refresh, size: 20),
            label: Text('Change'),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: primaryColor.withOpacity(0.5)),
              ),
            ),
          )
              : ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx','jpeg', 'jpg', 'png'],
              );

              if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LoadingAnimationWidget.staggeredDotsWave(
                              color: primaryColor,
                              size: 50,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Uploading $label...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please wait while we process your file',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                BlocProvider.of<ApplyJobBloc>(context).add(
                  UploadDocumentEvent(filePath: result.files.single.path!),
                );

                Future.delayed(Duration(milliseconds: 500), () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Upload',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context,
      TextEditingController controller,
      String label,
      Size screenSize, {
        int maxLines = 1,
        IconData? icon,
        String? hintText,
      }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: icon != null ? Icon(icon, color: primaryColor, size: 20) : null,
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 16 : 0,
            horizontal: icon != null ? 0 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, Size screenSize) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (documentUrls['resume']!.isEmpty) {
            SnackBarUtils.showRedSnackBar('Please upload your resume', context);
            return;
          }
          final contactInfo = {
            'email': emailController.text,
            'phone': phoneController.text,
          };
          final experiencesList = experiences.map((exp) => {
            'designation': exp['designation']!.text,
            'company': exp['company']!.text,
            'duration': exp['duration']!.text,
            'description': exp['description']!.text,
          }).toList();

          BlocProvider.of<ApplyJobBloc>(context).add(
            SubmitApplication(
              jobId: widget.jobId,
              isFresher: isFresher,
              experiences: experiencesList,
              contactInfo: contactInfo,
              resumeUrl: documentUrls['resume']!,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 20),
            SizedBox(width: 10),
            Text(
              'Submit Application',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}