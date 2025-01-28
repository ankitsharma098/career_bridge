import 'dart:ui';

import 'package:android/core/constants/colors.dart';
import 'package:android/core/utils/custonErrorUtils.dart';
import 'package:android/data/models/company/company_model.dart';
import 'package:android/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../data/models/employer/employer_model.dart';

class EmployerProfileScreen extends StatefulWidget {

  const EmployerProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {

  @override
  void initState() {
    BlocProvider.of<ProfileBloc>(context).add(FetchProfileData());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileDataLoading) {
          return Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.primary, size: 30),);

        } else if (state is ProfileDataLoaded) {
          return _buildLoadedState(context, state,state.companyDetails,screenSize);

        } else if (state is ProfileError) {
          return CustomErrorScreen(message: state.error,onRetry: (){
            BlocProvider.of<ProfileBloc>(context).add(FetchProfileData());
          },);
        }
        return Container();
      },
    );
  }

  Widget _buildLoadedState(BuildContext context, ProfileDataLoaded state,CompanyDetails companyDetails,Size screenSize) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(state.employer,companyDetails,screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildInfoCards(context,state,screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Employer employer, CompanyDetails companyDetails,Size screenSize) {

    return SliverAppBar(
      expandedHeight: 340,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.9],
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade800,
                    Colors.blue.shade700,
                  ],
                ),
              ),
            ),
            // Animated pattern overlay with shimmer effect
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withOpacity(0.5)],
                ).createShader(rect);
              },
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
            // Company logo with enhanced blur effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.network(
                      '${companyDetails.companyLogo}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Profile content with enhanced styling
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: 'profile_image',
                      child: CircleAvatar(
                        backgroundImage: employer.personalInfo.profilePic != null
                            ? NetworkImage(employer.personalInfo.profilePic!)
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height*0.02),
                  Text(
                    employer.personalInfo.fullName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: screenSize.width*0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    )
                  ),
                  SizedBox(height: screenSize.height*0.01),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      employer.companyDetails.designation,
                      style:Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: screenSize.width*0.045,
                        color: AppColors.background,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height*0.01),
                  Text(
                    employer.personalInfo.email,
                    style:Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: screenSize.width*0.04,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                  ),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoCards(BuildContext context, ProfileDataLoaded state,Size screenSize) {
    return Column(
      children: [
        _buildInfoCard(
          'Personal Information',
          Icons.person,
          _buildPersonalInfoContent(state.employer,screenSize),
          screenSize,
          onEdit: () => _editPersonalInfo(context, state.employer,screenSize),
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          'Company Details',
          Icons.business,
          _buildCompanyDetailsContent(state.companyDetails,screenSize),
          screenSize,
          onEdit: () => _editCompanyDetails(context, state.companyDetails,screenSize),
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          'Social Links',
          Icons.share,
          _buildSocialLinksContent(state.companyDetails.socialAccount,screenSize),
          screenSize,
          onEdit: () => _editSocialLinks(context, state.companyDetails.socialAccount,screenSize),
        ),
      ],
    );
  }
  Widget _buildInfoCard(String title, IconData icon, Widget content, Size screenSize, {VoidCallback? onEdit}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation:  0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Card(
                      shape: CircleBorder(),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(icon, color: AppColors.primary, size: 24),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                        fontSize:  screenSize.width*0.04,
                      )
                    ),
                  ],
                ),
                if (onEdit != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: onEdit,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          color:AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailsContent(CompanyDetails companyDetails,Size screenSize) {
    return Column(
      children: [
        _buildInfoListTile(
          Icons.business_center,
          'Company Name',
          companyDetails.companyName,
          screenSize
        ),
        _buildInfoListTile(
          Icons.web,
          'Website',
          companyDetails.website,
            screenSize
        ),
        _buildInfoListTile(
          Icons.category,
          'Industry Type',
          companyDetails.industryType,
            screenSize
        ),
      ],
    );
  }

  Widget _buildSocialLinksContent(SocialAccount socialAccount,Size screenSize) {
    return Column(
      children: [
        _buildInfoListTile(
          Icons.link,
          'LinkedIn',
          socialAccount.linkedin.isEmpty ? 'Not provided' : socialAccount.linkedin,
            screenSize
        ),
        _buildInfoListTile(
          Icons.camera_alt,
          'Instagram',
          socialAccount.instagram.isEmpty ? 'Not provided' : socialAccount.instagram,
            screenSize
        ),
        _buildInfoListTile(
          Icons.flutter_dash,
          'Twitter',
          socialAccount.twitter.isEmpty ? 'Not provided' : socialAccount.twitter,
            screenSize
        ),
      ],
    );
  }






  Widget _buildPersonalInfoContent(Employer employer,Size screenSize) {
    return Column(
      children: [
        _buildInfoListTile(
          Icons.work,
          'Designation',
          employer.companyDetails.designation,
          screenSize
        ),
        _buildInfoListTile(
          Icons.email,
          'Email',
          employer.personalInfo.email,
            screenSize
        ),
        _buildInfoListTile(
          Icons.phone,
          'Phone',
          employer.personalInfo.phoneNumber,
            screenSize
        ),
        _buildInfoListTile(
          Icons.location_on,
          'Address',
          employer.personalInfo.address,
            screenSize
        ),
        _buildInfoListTile(
          Icons.cake,
          'Date of Birth',
          employer.personalInfo.DOB?.toString() ?? 'Not provided',
            screenSize
        ),
        _buildInfoListTile(
          Icons.person_outline,
          'Gender',
          employer.personalInfo.gender,
            screenSize
        ),
      ],
    );
  }

  Widget _buildInfoListTile(IconData icon, String label, String value, Size screenSize) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(color: Colors.grey.shade300)),

      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 20),
        ),
        title: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: screenSize.width*0.04
          )
        ),
        subtitle: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 0.2,
            fontSize: screenSize.width*0.03,
            fontWeight: FontWeight.w300

          ),
        ),
      ),
    );
  }






  void _editPersonalInfo(BuildContext context, Employer employer,Size screenSize) {
    TextEditingController fullNameController = TextEditingController(text: employer.personalInfo.fullName);
    TextEditingController emailController = TextEditingController(text: employer.personalInfo.email);
    TextEditingController phoneController = TextEditingController(text: employer.personalInfo.phoneNumber);
    TextEditingController addressController = TextEditingController(text: employer.personalInfo.address);
    TextEditingController designationController = TextEditingController(text: employer.companyDetails.designation);
    TextEditingController dobController = TextEditingController(text: employer.personalInfo.DOB.toString());
    TextEditingController genderController = TextEditingController(text: employer.personalInfo.gender);


    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.all(2),
          child: SingleChildScrollView(
            child: Container(
              width: screenSize.width*0.88,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Personal Info',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: screenSize.height*0.03),
                  _buildTextField(fullNameController, 'Full Name', Icons.person),
                  _buildTextField(designationController, 'Designation', Icons.work),
                  _buildTextField(emailController, 'Email', Icons.email),
                  _buildTextField(phoneController, 'Phone Number', Icons.phone),
                  _buildTextField(addressController, 'Address', Icons.location_on),
                  _buildDOBField(dobController),
                  _buildTextField(genderController, 'Gender', Icons.person_outline),
                  SizedBox(height: screenSize.height*0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(
                            UpdatePersonalInfoDialog({
                              'fullName': fullNameController.text,
                              'email': emailController.text,
                              'phoneNumber': phoneController.text,
                              'address': addressController.text,
                            }),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Save Changes',  style: Theme.of(context).textTheme.bodySmall,),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editCompanyDetails(BuildContext context, CompanyDetails companyDetails,Size screenSize) {
    TextEditingController companyNameController = TextEditingController(text: companyDetails.companyName);
    TextEditingController websiteController = TextEditingController(text: companyDetails.website);
    TextEditingController industryTypeController = TextEditingController(text: companyDetails.industryType);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
          insetPadding: EdgeInsets.all(2),
          child: Container(
            width: screenSize.width*0.88,
            padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Company Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: screenSize.height*0.03),
                  _buildTextField(companyNameController, 'Company Name', Icons.business),
                  _buildTextField(websiteController, 'Website', Icons.web),
                  _buildTextField(industryTypeController, 'Industry Type', Icons.category),
                  SizedBox(height: screenSize.height*0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Add your company details update logic here
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Save Changes',style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editSocialLinks(BuildContext context, SocialAccount socialAccount,Size screenSize) {
    TextEditingController linkedinController = TextEditingController(text: socialAccount.linkedin);
    TextEditingController instagramController = TextEditingController(text: socialAccount.instagram);
    TextEditingController twitterController = TextEditingController(text: socialAccount.twitter);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.all(2),
          child: Container(
            width: screenSize.width*0.88,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Social Links',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: screenSize.height*0.03),
                _buildTextField(linkedinController, 'LinkedIn', Icons.link),
                _buildTextField(instagramController, 'Instagram', Icons.camera_alt),
                _buildTextField(twitterController, 'Twitter', Icons.flutter_dash),
                SizedBox(height: screenSize.height*0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Add your social links update logic here
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Save Changes',style: Theme.of(context).textTheme.bodySmall,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isMultiLine = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: isMultiLine ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDOBField (TextEditingController _dobController){

    Future<void> _selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900), // Earliest year
        lastDate: DateTime.now(),  // Latest year
      );

      if (pickedDate != null) {
        setState(() {
          _dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        });
      }
    }

    return TextFormField(
      controller: _dobController,
      readOnly: true, // Prevents manual editing
        decoration: InputDecoration(
        labelText: "Date of Birth",
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),

        ),
      onTap: () => _selectDate(context), // Opens the date picker
    );

  }

}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    double spacing = 20;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}