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
    on<DeleteResume>(_onDeleteResume);
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
        designation: personalInfo['designation'],
        gender: personalInfo['gender'],
      );
      await HiveUtils.updateCandidateData({
        'personalInfo': updatedPersonalInfo, // API returns updated personalInfo
      });
      emit(ProfileUpdateSuccess('Personal info updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileSummary(UpdateProfileSummary event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedSummary = await apiService.updateProfileSummary(event.summary);
      await HiveUtils.updateCandidateData({
        'profileSummary': updatedSummary, // API returns updated summary
      });
      emit(ProfileUpdateSuccess('Profile summary updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateAbout(UpdateAbout event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedAbout = await apiService.updateAbout(event.about);
      await HiveUtils.updateCandidateData({
        'about': updatedAbout, // API returns updated about
      });
      emit(ProfileUpdateSuccess('About updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'disabilityDetails': updatedDisabilityDetails, // API returns updated disabilityDetails
      });
      emit(ProfileUpdateSuccess('Disability details updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'jobPreferences': updatedJobPreferences, // API returns updated jobPreferences
      });
      emit(ProfileUpdateSuccess('Job preferences updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateSkills(UpdateSkills event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final updatedSkills = await apiService.updateSkills(event.skills);
      await HiveUtils.updateCandidateData({
        'skills': updatedSkills, // API returns updated skills
      });
      emit(ProfileUpdateSuccess('Skills updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAddEducation(AddEducation event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final newEducation = await apiService.addEducation(
        course: event.education.course,
        specialization: event.education.specialization,
        institution: event.education.institution,
        startingYear: event.education.startingYear,
        passingYear: event.education.passingYear,
        cgpa: event.education.cgpa,
      );
      await HiveUtils.updateCandidateData({
        'education': [newEducation], // API returns complete education with id
      });
      emit(ProfileUpdateSuccess('Education added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
        cgpa: event.education.cgpa,
      );
      await HiveUtils.updateCandidateData({
        'education': [updatedEducation], // API returns updated education
      });
      emit(ProfileUpdateSuccess('Education updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteEducation(DeleteEducation event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteEducation(event.id);
      await HiveUtils.updateCandidateData({
        'education': [{'id': event.id, 'delete': true}], // Local delete
      });
      emit(ProfileUpdateSuccess('Education deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'workExperience': [newWorkExperience], // API returns complete workExperience with id
      });
      emit(ProfileUpdateSuccess('Work experience added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'workExperience': [updatedWorkExperience], // API returns updated workExperience
      });
      emit(ProfileUpdateSuccess('Work experience updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteWorkExperience(DeleteWorkExperience event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteWorkExperience(event.id);
      await HiveUtils.updateCandidateData({
        'workExperience': [{'id': event.id, 'delete': true}], // Local delete
      });
      emit(ProfileUpdateSuccess('Work experience deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'internships': [newInternship], // API returns complete internship with id
      });
      emit(ProfileUpdateSuccess('Internship added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
        description: event.intern.descriptions,
        projectUrl: event.intern.projectUrl,
      );
      await HiveUtils.updateCandidateData({
        'internships': [updatedInternship], // API returns updated internship
      });
      emit(ProfileUpdateSuccess('Internship updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteInternship(DeleteInternship event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteInternship(event.id);
      await HiveUtils.updateCandidateData({
        'internships': [{'id': event.id, 'delete': true}], // Local delete
      });
      emit(ProfileUpdateSuccess('Internship deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'projects': [newProject], // API returns complete project with id
      });
      emit(ProfileUpdateSuccess('Project added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'projects': [updatedProject], // API returns updated project
      });
      emit(ProfileUpdateSuccess('Project updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteProject(DeleteProject event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteProject(event.id);
      await HiveUtils.updateCandidateData({
        'projects': [{'id': event.id, 'delete': true}], // Local delete
      });
      emit(ProfileUpdateSuccess('Project deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAddCertification(AddCertification event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      final newCertification = await apiService.addCertification(
        name: event.cert.name,
        issuingOrganization: event.cert.issuingOrganization,
        issueDate: event.cert.issueDate,
        credentialID: event.cert.credentialID,
        url: event.cert.url,
      );
      await HiveUtils.updateCandidateData({
        'certifications': [newCertification], // API returns complete certification with id
      });
      emit(ProfileUpdateSuccess('Certification added successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      await HiveUtils.updateCandidateData({
        'certifications': [updatedCertification], // API returns updated certification
      });
      emit(ProfileUpdateSuccess('Certification updated successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteCertification(DeleteCertification event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      await apiService.deleteCertification(event.id);
      await HiveUtils.updateCandidateData({
        'certifications': [{'id': event.id, 'delete': true}], // Local delete
      });
      emit(ProfileUpdateSuccess('Certification deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteResume(DeleteResume event, Emitter<CandidateProfileState> emit) async {
    try {
      // Update implementation
      // final updatedResume = await apiService.deleteResume(); // Assume API returns empty string or null
      // await HiveUtils.updateCandidateData({
      //   'resume': updatedResume ?? '', // API returns updated resume (empty)
      // });
      emit(ProfileUpdateSuccess('Resume deleted successfully'));
      // Refresh data
      add(FetchProfileData());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
