part of 'candidate_profile_bloc.dart';

@immutable
sealed class CandidateProfileEvent {}

class FetchProfileData extends CandidateProfileEvent {}
class UpdateProfile extends CandidateProfileEvent { final PersonalInfo info; UpdateProfile(this.info); }
class UpdateProfileSummary extends CandidateProfileEvent { final String summary; UpdateProfileSummary(this.summary); }
class UpdateAbout extends CandidateProfileEvent { final String about; UpdateAbout(this.about); }
class UpdateDisabilityDetails extends CandidateProfileEvent { final DisabilityDetails details; UpdateDisabilityDetails(this.details); }
class UpdateJobPreferences extends CandidateProfileEvent { final JobPreferences prefs; UpdateJobPreferences(this.prefs); }
class UpdateWorkExperience extends CandidateProfileEvent { final WorkExperience workExperience; UpdateWorkExperience(this.workExperience); }
class AddWorkExperience extends CandidateProfileEvent { final WorkExperience workExperience; AddWorkExperience(this.workExperience); }
class UpdateInternship extends CandidateProfileEvent { final Internship intern; UpdateInternship(this.intern); }
class AddInternship extends CandidateProfileEvent { final Internship intern; AddInternship(this.intern); }
class UpdateCertification extends CandidateProfileEvent { final Certification cert; UpdateCertification(this.cert); }
class AddCertification extends CandidateProfileEvent { final Certification cert; AddCertification(this.cert); }
class UpdateSkills extends CandidateProfileEvent { final List<String> skills; UpdateSkills(this.skills); }
class UpdateProject extends CandidateProfileEvent { final Project project; UpdateProject(this.project); }
class AddProject extends CandidateProfileEvent { final Project project; AddProject(this.project); }
class AddEducation extends CandidateProfileEvent { final Education education; AddEducation(this.education); }
class UpdateEducation extends CandidateProfileEvent { final Education education; UpdateEducation(this.education); }
class DeleteEducation extends CandidateProfileEvent { final String id; DeleteEducation(this.id); }
class DeleteResume extends CandidateProfileEvent {}
class DeleteWorkExperience extends CandidateProfileEvent { final String id; DeleteWorkExperience(this.id); }
class DeleteInternship extends CandidateProfileEvent { final String id; DeleteInternship(this.id); }
class DeleteProject extends CandidateProfileEvent { final String id; DeleteProject(this.id); }
class DeleteCertification extends CandidateProfileEvent { final String id; DeleteCertification(this.id); }