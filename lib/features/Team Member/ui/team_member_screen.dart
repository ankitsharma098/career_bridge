import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android/core/constants/colors.dart';
import 'package:android/data/models/employer/employer_model.dart';
import '../bloc/team_member_bloc.dart';
import '../bloc/team_member_event.dart';
import '../bloc/team_member_state.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddEmployerDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<TeamMembersBloc, TeamMembersState>(
        listener: (BuildContext context, TeamMembersState state) {
          if( state is TeamMembersLoading){
             CircularProgressIndicator();
          }
        },
        builder: (context, state) {
          if (state is TeamMembersLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TeamMembersLoaded) {
            final teamMembers = state.teamMembers;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Your Team',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: teamMembers.isEmpty
                        ? Center(child: Text('No team members yet.'))
                        : ListView.builder(
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = teamMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(member.personalInfo.fullName[0]),
                          ),
                          title: Text(member.personalInfo.fullName),
                          subtitle: Text(member.personalInfo.email),
                          trailing: widget.currentEmployer.role == 'admin' && member.id != widget.currentEmployer.id
                              ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmationDialog(context, member.id),
                          )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is TeamMembersFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return Container();
        },
      ),
    );
  }

  void _showAddEmployerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Team Member'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final employerData = {
                  'fullName': nameController.text,
                  'email': emailController.text,
                  'phoneNumber': phoneController.text,
                  'designation': 'Team Member',
                  'password': 'defaultPassword', // Adjust as needed
                };
                BlocProvider.of<TeamMembersBloc>(context).add(
                  AddTeamMemberEvent(companyId: widget.companyId, employerData: employerData),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String employerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Team Member'),
        content: Text('Are you sure you want to delete this team member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<TeamMembersBloc>(context).add(
                DeleteTeamMemberEvent(employerId: employerId, companyId: widget.companyId),
              );
              Navigator.pop(context);
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}