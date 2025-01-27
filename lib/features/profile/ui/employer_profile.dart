import 'package:android/core/constants/colors.dart';
import 'package:android/data/models/company/company_model.dart';
import 'package:android/data/models/employer/employer_model.dart';
import 'package:android/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/snackBarUtils.dart';

class EmployerProfile extends StatefulWidget {
  final Employer? employer;
  final CompanyDetails?  companyDetails;
  const EmployerProfile({super.key, required this.employer, required this.companyDetails});

  @override
  State<EmployerProfile> createState() => _EmployerProfileState();
}

class _EmployerProfileState extends State<EmployerProfile> {


  bool isEditingPersonal = false;
  bool isEditingSocial = false;
  bool isEditingCompany = false;

  // Controllers for personal info
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Controllers for social media
  late TextEditingController linkedinController;
  late TextEditingController instagramController;
  late TextEditingController twitterController;

  // Controllers for company info
  late TextEditingController companyNameController;
  late TextEditingController websiteController;
  late TextEditingController aboutController;

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  void initializeControllers() {
    // Personal info controllers
    nameController = TextEditingController(text: widget.employer?.personalInfo.fullName);
    emailController = TextEditingController(text: widget.employer?.personalInfo.email);
    phoneController = TextEditingController(text: widget.employer?.personalInfo.phoneNumber);

    // Social media controllers
    linkedinController = TextEditingController(text: widget.companyDetails?.socialAccount.linkedin);
    instagramController = TextEditingController(text: widget.companyDetails?.socialAccount.instagram);
    twitterController = TextEditingController(text: widget.companyDetails?.socialAccount.twitter);

    // Company info controllers
    companyNameController = TextEditingController(text: widget.companyDetails?.companyName);
    websiteController = TextEditingController(text: widget.companyDetails?.website);
    aboutController = TextEditingController(text: widget.companyDetails?.about);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    linkedinController.dispose();
    instagramController.dispose();
    twitterController.dispose();
    companyNameController.dispose();
    websiteController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocConsumer<ProfileBloc, ProfileState>(
  listener: (context, state) {
    if (state is EmployerProfileUpdateSuccess) {

      SnackBarUtils.showGreenSnackBar(state.message.toString(), context);

    } else if (state is EmployerProfileError) {

      SnackBarUtils.showRedSnackBar(state.error.toString(), context);
    }
  },
  builder: (context, state) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(screenSize),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 20),
                  _buildTabSections(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
);
  }

  Widget _buildSliverAppBar(Size screenSize) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.companyDetails?.companyLogo ?? 'https://placeholder.com/background',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
        title: Text(
           'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenSize.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 60),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                widget.employer?.personalInfo.fullName ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.employer?.companyDetails.designation ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              _buildQuickStats(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: widget.employer?.personalInfo.profilePic != null
                  ? NetworkImage(widget.employer!.personalInfo.profilePic!)
                  : null,
              child: widget.employer?.personalInfo.profilePic == null
                  ? Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Posted Jobs', widget.employer?.postedJobs.length.toString() ?? '0'),
        _buildVerticalDivider(),
        _buildStatItem('Stories', widget.employer?.stories.myStoryIds.length.toString() ?? '0'),
        _buildVerticalDivider(),
        _buildStatItem('Events', widget.employer?.events.myEventIds.length.toString() ?? '0'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildTabSections() {
    return Column(
      children: [
        _buildSectionCard(
          'Personal Information',
          isEditingPersonal,
          [
            _buildAnimatedInfoField('Name', nameController, isEditingPersonal),
            _buildAnimatedInfoField('Email', emailController, isEditingPersonal),
            _buildAnimatedInfoField('Phone', phoneController, isEditingPersonal),
          ],
          onEdit: (){
          if(isEditingPersonal==true){
            BlocProvider.of<ProfileBloc>(context).add(UpdatePersonalInfo(name: nameController.text, email: emailController.text , phone: phoneController.text, address: null, DOB: null, profilePic: null, designation: null,));
          }
           setState(() {
             isEditingPersonal=!isEditingPersonal;
           });
          },
        ),
        SizedBox(height: 20),
        _buildSectionCard(
          'Social Media',
          isEditingSocial,
          [
            _buildSocialMediaField('LinkedIn', linkedinController, isEditingSocial, Icons.dataset_linked),
            _buildSocialMediaField('Instagram', instagramController, isEditingSocial, Icons.social_distance),
            _buildSocialMediaField('Twitter', twitterController, isEditingSocial, Icons.twelve_mp),
          ],
          onEdit: (){
            BlocProvider.of<ProfileBloc>(context).add(UpdateSocialMedia(linkedinController.text, twitterController.text, instagramController.text));
            setState(() => isEditingSocial = !isEditingSocial);
          },
        ),
        SizedBox(height: 20),
        _buildSectionCard(
          'Company Information',
          isEditingCompany,
          [
            _buildAnimatedInfoField('Company Name', companyNameController, isEditingCompany),
            _buildAnimatedInfoField('Website', websiteController, isEditingCompany),
            _buildAnimatedInfoField('About', aboutController, isEditingCompany, maxLines: 3),
          ],
          onEdit: () => setState(() => isEditingCompany = !isEditingCompany),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, bool isEditing, List<Widget> children,
      {required VoidCallback onEdit}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isEditing
                ? AppColors.primary.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: isEditing ? 3 : 1,
            blurRadius: isEditing ? 10 : 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isEditing ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isEditing ? Icons.save : Icons.edit,
                      color: isEditing ? Colors.white : Colors.grey[600],
                    ),
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedInfoField(
      String label, TextEditingController controller, bool isEditing,
      {int maxLines = 1}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: isEditing
                ? TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
                : Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                controller.text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaField(
      String label, TextEditingController controller, bool isEditing, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 16),
          Expanded(
            child: _buildAnimatedInfoField(label, controller, isEditing),
          ),
        ],
      ),
    );
  }
}