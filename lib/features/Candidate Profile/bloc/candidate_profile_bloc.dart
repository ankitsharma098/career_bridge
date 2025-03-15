import 'dart:io';

import 'package:android/data/models/employer/employer_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/candidate/candidate_model.dart';
import '../data/data_service.dart';

part 'candidate_profile_event.dart';
part 'candidate_profile_state.dart';

class CandidateProfileBloc extends Bloc<CandidateProfileEvent, CandidateProfileState> {
  CandidateProfileApi apiService = CandidateProfileApi();
  CandidateProfileBloc() : super(CandidateProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
    on<UpdatePersonalProfile>(_onUpdatePersonalProfile);
    on<UpdateProfileSummary>(_onUpdateProfileSummary);
    on<UpdateAbout>(_onUpdateAbout);
    on<UpdateDisabilityDetails>(_onUpdateDisabilityDetails);
    on<UpdateJobPreferences>(_onUpdateJobPreferences);
    on<UpdateSkills>(_onUpdateSkills);
    on<AddEducation>(_onAddEducation);
    on<UpdateEducation>(_onUpdateEducation);
    on<DeleteEducation>(_onDeleteEducation);
    on<AddWorkExperience>(_onAddWorkExperience);
    on<UpdateWorkExperience>(_onUpdateWorkExperience);
    on<DeleteWorkExperience>(_onDeleteWorkExperience);
    on<AddInternship>(_onAddInternship);
    on<UpdateInternship>(_onUpdateInternship);
    on<DeleteInternship>(_onDeleteInternship);
    on<AddProject>(_onAddProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<AddCertification>(_onAddCertification);
    on<UpdateCertification>(_onUpdateCertification);
    on<DeleteCertification>(_onDeleteCertification);
    on<UploadResume>(_onUploadResume);
    on<UploadDocumentEvent>(_onUploadDocument);
  }
  Future<void> _onFetchProfileData(FetchProfileData event, Emitter<CandidateProfileState> emit) async {
    emit(ProfileDataLoading());
    try {
      print("FetchProfileData");

      Map<String,dynamic> candidateData=await HiveUtils.getCandidateData();

      if (candidateData.isEmpty) {
        emit(ProfileError('No data found'));
        return;
      }
      print("before candidate Profile data loaded");
      Candidate candidate = Candidate.fromJson(candidateData);
      print("candidate $candidate");

      emit(ProfileDataLoaded(candidate));
      print("after candidate Profile data loaded");
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdatePersonalProfile(UpdatePersonalProfile event, Emitter<CandidateProfileState> emit) async {
    try {
      final personalInfo = event.personalInfo;

      print('//personalInfo $personalInfo');
      // Update implementation
      final updatedPersonalInfo = await apiService.updatePersonalInfo(
        fullName: personalInfo['fullName'],
        profilePicFile: personalInfo['profilePic'],
        email: personalInfo['email'],
        phoneNumber: personalInfo['phoneNumber'],
        address: personalInfo['address'],
        DOB: personalInfo['DOB'],
        gender: personalInfo['gender'],
        publicId: personalInfo['publicId'],
      );

       var dob= updatedPersonalInfo["DOB"];

       print("dob ${dob}");


      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['personalInfo'] =updatedPersonalInfo;
      await HiveUtils.updateCandidateData(candidateData);


      emit(ProfileUpdateSuccess('Personal info updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateProfileSummary(UpdateProfileSummary event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedSummary = await apiService.updateProfileSummary(event.summary);

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['profileSummary'] = updatedSummary;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Profile summary updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateAbout(UpdateAbout event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedAbout = await apiService.updateAbout(event.about);

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['about'] = updatedAbout;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('About updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateDisabilityDetails(UpdateDisabilityDetails event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedDisabilityDetails = await apiService.updateDisabilityDetails(
        type: event.details.type,
        percentage: event.details.percentage.toString(),
        certificateNumber: event.details.certificateNumber,
        certificateDoc: event.details.certificateDoc,
        publicId: event.details.publicId,
        accommodationsNeeded: event.details.accommodationsNeeded,
        assistiveTechnology: event.details.assistiveTechnology,
        preferredCommunicationMethod: event.details.preferredCommunicationMethod,
      );

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['disabilityDetails'] = updatedDisabilityDetails.toJson();
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Disability details updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateJobPreferences(UpdateJobPreferences event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedJobPreferences = await apiService.updateJobPreferences(
        industries: event.prefs.industries,
        roles: event.prefs.roles,
        preferredSalary: event.prefs.preferredSalary.toString(),
        location: event.prefs.location,
        workMode: event.prefs.workMode,
        employmentType: event.prefs.employmentType,
        experienceLevel: event.prefs.experienceLevel,
      );
      print('Updated Job Preferences: ${updatedJobPreferences.toJson()}');

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['jobPreferences'] = updatedJobPreferences.toJson();
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Job preferences updated successfully'));
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateSkills(UpdateSkills event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedSkills = await apiService.updateSkills(event.skills);

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      candidateData['skills'] = updatedSkills;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Skills updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onAddEducation(AddEducation event, Emitter<CandidateProfileState> emit) async {
    try {

      print("_onAddEducation Event");
      final newEducation = await apiService.addEducation(
        course: event.education.course,
        specialization: event.education.specialization,
        institution: event.education.institution,
        startingYear: event.education.startingYear,
        passingYear: event.education.passingYear,
        CGPA: event.education.CGPA,
      );
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['education'] ??= [];

      // Add new education to the list
      candidateData['education'].add(newEducation.toJson());

      print('Updated JnewEducation-----------------------------------------------------------: ${newEducation.toJson()}');
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Education added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateEducation(UpdateEducation event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedEducation = await apiService.updateEducation(
        id: event.education.id,
        course: event.education.course,
        specialization: event.education.specialization,
        institution: event.education.institution,
        startingYear: event.education.startingYear,
        passingYear: event.education.passingYear,
        CGPA: event.education.CGPA,
      );

      print('Updated Job Preferences: ${updatedEducation.toJson()}');
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      List<dynamic> educationList = candidateData['education'] ?? [];
      for (int i = 0; i < educationList.length; i++) {
        if (educationList[i]['_id'] == event.education.id) {
          educationList[i] = updatedEducation.toJson();
          break;
        }
      }
      candidateData['education'] = educationList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Education updated successfully'));
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onDeleteEducation(DeleteEducation event, Emitter<CandidateProfileState> emit) async {
    try {

      await apiService.deleteEducation(event.id);
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      List<dynamic> educationList = candidateData['education'] ?? [];

      print("Before educationList $educationList");
      educationList.removeWhere((item) => item['_id'] == event.id);

      print("After educationList $educationList");
      candidateData['education'] = educationList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Education deleted successfully'));
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onAddWorkExperience(AddWorkExperience event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final newWorkExperience = await apiService.addWorkExperience(
        company: event.workExperience.company,
        position: event.workExperience.position,
        startDate: event.workExperience.startDate,
        endDate: event.workExperience.endDate,
        descriptions: event.workExperience.descriptions,
      );

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      candidateData['workExperience'] ??= [];
      candidateData['workExperience'].add(newWorkExperience.toJson());

      await HiveUtils.updateCandidateData(candidateData);
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateWorkExperience(UpdateWorkExperience event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedWorkExperience = await apiService.updateWorkExperience(
        id: event.workExperience.id,
        company: event.workExperience.company,
        position: event.workExperience.position,
        startDate: event.workExperience.startDate,
        endDate: event.workExperience.endDate,
        descriptions: event.workExperience.descriptions,

      );
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> workExperienceList = candidateData['workExperience'] ?? [];
      for (int i = 0; i < workExperienceList.length; i++) {
        if (workExperienceList[i]['_id'] == event.workExperience.id) {
          workExperienceList[i] = updatedWorkExperience.toJson();
          break;
        }
      }
      candidateData['workExperience'] = workExperienceList;
      await HiveUtils.updateCandidateData(candidateData);
      emit(ProfileUpdateSuccess('Work experience updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onDeleteWorkExperience(DeleteWorkExperience event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteWorkExperience(event.id);
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> workExperienceList = candidateData['workExperience'] ?? [];
      workExperienceList.removeWhere((item) => item['_id'] == event.id);
      candidateData['workExperience'] = workExperienceList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Work experience deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onAddInternship(AddInternship event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final newInternship = await apiService.addInternship(
        company: event.intern.company,
        role: event.intern.role,
        startDate: event.intern.startDate,
        endDate: event.intern.endDate,
        projectName: event.intern.projectName,
        skills: event.intern.skills,
        descriptions: event.intern.descriptions,
        projectUrl: event.intern.projectUrl,
      );

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      candidateData['internships'] ??= [];
      candidateData['internships'].add(newInternship.toJson());
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Internship added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateInternship(UpdateInternship event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedInternship = await apiService.updateInternship(
        id: event.intern.id,
        company: event.intern.company,
        role: event.intern.role,
        startDate: event.intern.startDate,
        endDate: event.intern.endDate,
        projectName: event.intern.projectName,
        skills: event.intern.skills,
        descriptions: event.intern.descriptions,
        projectUrl: event.intern.projectUrl,
      );
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> internshipsList = candidateData['internships'] ?? [];
      for (int i = 0; i < internshipsList.length; i++) {
        if (internshipsList[i]['_id'] == event.intern.id) {
          internshipsList[i] = updatedInternship.toJson();
          break;
        }
      }
      candidateData['internships'] = internshipsList;
      await HiveUtils.updateCandidateData(candidateData);
      emit(ProfileUpdateSuccess('Internship updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());

    }
  }

  Future<void> _onDeleteInternship(DeleteInternship event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteInternship(event.id);

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> internshipsList = candidateData['internships'] ?? [];
      internshipsList.removeWhere((item) => item['_id'] == event.id);
      candidateData['internships'] = internshipsList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Internship deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onAddProject(AddProject event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final newProject = await apiService.addProject(
        projectName: event.project.projectName,
        startDate: event.project.startDate,
        endDate: event.project.endDate,
        descriptions: event.project.descriptions,
        skills: event.project.skills,
        projectUrl: event.project.projectUrl,
      );
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      candidateData['projects'] ??= [];
      candidateData['projects'].add(newProject.toJson());
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Project added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateProject(UpdateProject event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedProject = await apiService.updateProject(
        id: event.project.id,
        projectName: event.project.projectName,
        startDate: event.project.startDate,
        endDate: event.project.endDate,
        descriptions: event.project.descriptions,
        skills: event.project.skills,
        projectUrl: event.project.projectUrl,
      );
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> projectsList = candidateData['projects'] ?? [];
      for (int i = 0; i < projectsList.length; i++) {
        if (projectsList[i]['_id'] == event.project.id) {
          projectsList[i] = updatedProject.toJson();
          break;
        }
      }
      candidateData['projects'] = projectsList;
      await HiveUtils.updateCandidateData(candidateData);
      emit(ProfileUpdateSuccess('Project updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onDeleteProject(DeleteProject event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteProject(event.id);

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> projectsList = candidateData['projects'] ?? [];
      projectsList.removeWhere((item) => item['_id'] == event.id);
      candidateData['projects'] = projectsList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Project deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onAddCertification(AddCertification event, Emitter<CandidateProfileState> emit) async {
    try {

      print("Add certif bloc");
      final newCertification = await apiService.addCertification(
        name: event.cert.name,
        issuingOrganization: event.cert.issuingOrganization,
        issueDate: event.cert.issueDate,
        credentialID: event.cert.credentialID,
        url: event.cert.url,
      );

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      candidateData['certifications'] ??= [];
      candidateData['certifications'].add(newCertification.toJson());
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Certification added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUpdateCertification(UpdateCertification event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedCertification = await apiService.updateCertification(
        id: event.cert.id,
        name: event.cert.name,
        issuingOrganization: event.cert.issuingOrganization,
        issueDate: event.cert.issueDate,
        credentialID: event.cert.credentialID,
        url: event.cert.url,
      );
      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> certificationsList = candidateData['certifications'] ?? [];
      for (int i = 0; i < certificationsList.length; i++) {
        if (certificationsList[i]['_id'] == event.cert.id) {
          certificationsList[i] = updatedCertification.toJson();
          break;
        }
      }
      candidateData['certifications'] = certificationsList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Certification updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());

    }
  }

  Future<void> _onDeleteCertification(DeleteCertification event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteCertification(event.id);

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();
      List<dynamic> certificationsList = candidateData['certifications'] ?? [];
      certificationsList.removeWhere((item) => item['_id'] == event.id);
      candidateData['certifications'] = certificationsList;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Certification deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUploadResume(UploadResume event, Emitter<CandidateProfileState> emit) async {
    try {
      emit(ProfileDataLoading());

        print("UploadResume BLoc ");

        final result = await apiService.uploadResume(File(event.filePath));
        print("upload document ----------------$result");

      Map<String, dynamic> candidateData = await HiveUtils.getCandidateData();

      candidateData['resume'] = result;
      await HiveUtils.updateCandidateData(candidateData);

      emit(ProfileUpdateSuccess('Resume Uploaded successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }
  }

  Future<void> _onUploadDocument(UploadDocumentEvent event, Emitter<CandidateProfileState> emit) async{

    emit(ProfileDataLoading());

    try{
      print("documnent uploadtion hit ");

      final result = await apiService.uploadMedia(File(event.filePath));
      print("upload document ----------------$result");

      emit(DocumentUploaded(url: result['url'].toString(), publicId: result['publicId'].toString()));
      add(FetchProfileData()); //
    }catch (e) {
      emit(ProfileError(e.toString()));
      add(FetchProfileData());
    }


  }
}
