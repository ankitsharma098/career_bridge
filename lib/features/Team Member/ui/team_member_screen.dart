import 'package:android/core/utils/snackBarUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android/core/constants/colors.dart';
import 'package:android/data/models/employer/employer_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/utils/customErrorUtils.dart';
import '../../Chat/bloc/chat_bloc.dart';
import '../../Chat/data service/chat_service.dart';
import '../../Chat/ui/chat_screen.dart';
import '../../See profile/bloc/see_profile_bloc.dart';
import '../../See profile/ui/see_profile.dart';
import '../bloc/team_member_bloc.dart';
import '../bloc/team_member_event.dart';
import '../bloc/team_member_state.dart';

import 'package:cached_network_image/cached_network_image.dart';

class TeamMembersScreen extends StatefulWidget {
  final Employer currentEmployer;
  final String companyId;

  const TeamMembersScreen({super.key, required this.currentEmployer, required this.companyId});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    BlocProvider.of<TeamMembersBloc>(context).add(FetchTeamMembersEvent(widget.companyId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Team Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEmployerDialog(context),
              icon: Icon(Icons.add,color: Colors.white,),
              label: Text('Add'),

              style: ElevatedButton.styleFrom(
                //backgroundColor: primaryColor.withOpacity(0.5),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TeamMembersBloc, TeamMembersState>(
        listener: (BuildContext context, TeamMembersState state) {
          if (state is TeamMembersFailure) {
            SnackBarUtils.showRedSnackBar(state.error, context);
          }

          if (state is TeamMemberAdded) {
            SnackBarUtils.showGreenSnackBar("Team member added successfully!", context);

          }

          if (state is TeamMemberDeleted) {
            SnackBarUtils.showGreenSnackBar("Team member removed successfully!", context);

          }
        },
        builder: (context, state) {
          if (state is TeamMembersLoading) {
            return Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20),);
          } else if (state is TeamMembersLoaded) {
            List<Employer> teamMembers = state.teamMembers;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                      SizedBox(width: screenSize.width*0.02),
                      Text(
                        'Manage Your Team',
                        style: textTheme.displaySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height*0.01),
                  Text(
                    'Your team has ${teamMembers.length} members',
                    style: textTheme.bodySmall,
                  ),
                  SizedBox(height: screenSize.height*0.02),
                  Expanded(
                    child: teamMembers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                       Employer member = teamMembers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildTeamMemberCard(member,screenSize),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is TeamMembersFailure) {
            return CustomErrorScreen(message: state.error,onRetry: (){
              BlocProvider.of<TeamMembersBloc>(context)
                  .add(FetchTeamMembersEvent(widget.companyId));
            },);
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 80,
            color: secondaryTextColor,
          ),
          SizedBox(height: 24),
          Text(
            'No team members yet',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Add team members to collaborate and manage your projects together.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddEmployerDialog(context),
            icon: Icon(Icons.add),
            label: Text('Add Team Member'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(dynamic member,Size screenSize) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final isAdmin = member.role == 'admin';
    final isCurrentUser = member.id == widget.currentEmployer.id;

    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => SeeProfileBloc(),
              child: UserProfileScreen(
                userId: member.id,
                userType: "employer", currentUserId: widget.currentEmployer.id, currentUserType:"employer" , // Ensure StoryModel has type
              ),
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isAdmin
                ? (isDarkMode ? Colors.amber.withOpacity(0.5) : Colors.amber.shade300)
                : Colors.grey,
            width: isAdmin ? 1 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Profile Image
              if (member.personalInfo.profilePic != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: member.personalInfo.profilePic,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircleAvatar(
                      radius: 30,
                      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                      child: Icon(Icons.person, color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 30,
                      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                      child: Text(
                        member.personalInfo.fullName[0],
                        style: TextStyle(
                          fontSize: 24,
                          color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    member.personalInfo.fullName[0],
                    style: TextStyle(
                      fontSize: 24,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(width: 16),

              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.personalInfo.fullName,
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.blueGrey[700] : Colors.blueGrey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'You',
                              style: textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      member.personalInfo.email,
                      style: textTheme.bodySmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: screenSize.width*0.2,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? (isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.amber.withOpacity(0.2))
                                : (isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              isAdmin ? 'Admin' : member.companyDetails?.designation ?? 'Team Member',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenSize.width*0.03,
                                fontWeight: FontWeight.w500,
                                color: isAdmin
                                    ? (isDarkMode ? Colors.amber[200] : Colors.amber[800])
                                    : (isDarkMode ? Colors.blue[200] : Colors.blue[700]),
                              ),
                            ),
                          ),
                        ),
                        if (member.personalInfo.phoneNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              member.personalInfo.phoneNumber,
                              style: textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              if (widget.currentEmployer.role == 'admin' && !isCurrentUser)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.mail_outline,
                          color: isDarkMode ? Colors.blue[200] : Colors.blue[700]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => ChatBloc(
                                ChatRepository(),
                                member.id, // receiverId
                                 "employer", // receiverType
                                widget.currentEmployer.id, // Correct currentUserId
                                "employer",
                              ),
                              child: ChatScreen(
                                receiverId: member.id,
                                receiverType: "employer",
                                receiverName: member.personalInfo.fullName, profilePic: member.personalInfo.profilePic,
                              ),
                            ),
                          ),
                        );
                      },
                      tooltip: 'Send email',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () => _showDeleteConfirmationDialog(context, member.id),
                      tooltip: 'Remove member',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEmployerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final designationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final BuildContext parentContext = context;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Add Team Member'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: designationController,
                  decoration: InputDecoration(
                    labelText: 'Designation',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (value) => value!.isEmpty ? 'Designation is required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final employerData = {
                  'fullName': nameController.text,
                  'email': emailController.text,
                  'phoneNumber': phoneController.text,
                  'designation': designationController.text.isEmpty ? 'Team Member' : designationController.text,
                  'password': '1234', // Adjust as needed
                };
                BlocProvider.of<TeamMembersBloc>(parentContext).add(
                  AddTeamMemberEvent(companyId: widget.companyId, employerData: employerData),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String employerId) {
    final BuildContext parentContext=context;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            SizedBox(width: 8),
            Text('Delete Team Member'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove this team member? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              BlocProvider.of<TeamMembersBloc>(parentContext).add(
                DeleteTeamMemberEvent(employerId: employerId, companyId: widget.companyId),
              );
              Navigator.pop(dialogContext);
            },
            icon: Icon(Icons.delete,color: Colors.white,),
            label: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}