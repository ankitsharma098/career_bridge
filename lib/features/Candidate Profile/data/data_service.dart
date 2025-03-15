import 'dart:io';

import 'package:android/data/models/candidate/candidate_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/hiveUtils.dart';

class CandidateProfileApi {
  final dio = Dio();

  Future<Map<String, dynamic>> updatePersonalInfo({
    required String? fullName,
    required File? profilePicFile,
    required String? publicId,
    required String? email,
    required String? phoneNumber,
    required String? address,
    required String? DOB,
    required String? gender,
  }) async {
    try {
      print("updatePersonalInfo");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      print("accessToken");
      FormData formData = FormData.fromMap({});

      void addIfValid(String key, String? value) {
        if (value != null && value.isNotEmpty) {
          formData.fields.add(MapEntry(key, value));
        }
      }

      addIfValid('fullName', fullName);
      addIfValid('email', email);
      addIfValid('phoneNumber', phoneNumber);
      addIfValid('address', address);
      addIfValid('DOB', DOB);
      addIfValid('gender', gender);
      addIfValid('publicId', publicId);

      if (profilePicFile != null) {
        String extension = profilePicFile.path.split('.').last.toLowerCase();
        String mimeType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          default:
            throw Exception('Unsupported image type: $extension');
        }
        formData.files.add(
          MapEntry(
            'profilePic',
            await MultipartFile.fromFile(
              profilePicFile.path,
              filename: 'CandidateProfile.$extension',
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );

      }

      print("API hit data $formData");
      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/personalInfo",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          contentType: 'multipart/form-data',
        ),
        data: formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = (sent / total * 100).toStringAsFixed(2);
            print('Upload Progress: $progress%');
          }
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['personalInfo']);
      } else {
        throw Exception("Failed to Update Personal Info");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Map<String, String>> uploadMedia(File file) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      print('Uploading file: ${file.path}, MIME type: $mimeType');

      const allowedMimes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ];
      if (!allowedMimes.contains(mimeType)) {
        throw Exception('Unsupported file type: $mimeType. Allowed types: jpg, png, gif, pdf, doc, docx');
      }

      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await dio.post(
        "${AppConstants.baseUrl}/media/upload",
        data: formData,
        options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
      );

      return {
        'url': response.data['url'],
        'publicId': response.data['publicId'],
      };
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }


  Future<Map<String, dynamic>> uploadResume(File file) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      print('Uploading file: ${file.path}, MIME type: $mimeType');

      const allowedMimes = [
        'image/jpeg',
        'image/png',
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ];
      if (!allowedMimes.contains(mimeType)) {
        throw Exception('Unsupported file type: $mimeType. Allowed types: jpg, png, gif, pdf, doc, docx');
      }

      final formData = FormData.fromMap({
        'resume': await MultipartFile.fromFile(
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/resume",
        data: formData,
        options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
      );
      if (response.statusCode == 200) {


        print("response ${response.data}");
        print("response ${response.data['resume']}");
        return Map<String, dynamic>.from(response.data['resume']);
      } else {
        throw Exception("Failed to Update resume");
      }

    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> updateProfileSummary(String? summary) async {
    try {
      print("updateProfileSummary");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> date ={
        'profileSummary': summary,
      };

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/profileSummary",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: 'application/json',
        ),
        data: date,
      );

      if (response.statusCode == 200) {
        return response.data['profileSummary'] as String;
      } else {
        throw Exception("Failed to Update Profile Summary");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String> updateAbout(String? about) async {
    try {
      print("updateAbout");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'about': about,
      };

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/about",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data['about'] as String;
      } else {
        throw Exception("Failed to Update About");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<DisabilityDetails> updateDisabilityDetails({
    required String? type,
    required String? percentage,
    required String? certificateNumber,
    required String? certificateDoc, // Now a URL, not a file
    required String? publicId,
    required List? accommodationsNeeded,
    required String? preferredCommunicationMethod,
    required List? assistiveTechnology,
  }) async {
    try {
      print("updateDisabilityDetails");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      final data = {
        'type': type,
        'percentage': percentage,
        'certificateNumber': certificateNumber,
        'certificateDoc': certificateDoc,
        'publicId': publicId,
        'accommodationsNeeded': accommodationsNeeded,
        'preferredCommunicationMethod': preferredCommunicationMethod,
        'assistiveTechnology': assistiveTechnology,
      };

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/disabilityDetails",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: 'application/json',
        ),
        data: data,
      );

      if (response.statusCode == 200) {

        Map<String,dynamic> rawDisabilityDetails=Map<String, dynamic>.from(response.data['disabilityDetails']);
        DisabilityDetails disabilityDetails = DisabilityDetails.fromJson(rawDisabilityDetails);
        return disabilityDetails;
      } else {
        throw Exception("Failed to Update Disability Details");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<JobPreferences> updateJobPreferences({
    required List<String>? industries,
    required List<String>? roles,
    required String? preferredSalary,
    required List<String>? location,
    required String? workMode,
    required List<String>? employmentType,
    required String? experienceLevel,
  }) async {
    try {
      print("updateJobPreferences");

      Map<String,dynamic> data = {
        "industries":industries,
        "roles":roles,
        "preferredSalary":int.parse(preferredSalary!),
        "location":location,
        "workMode":workMode,
        "employmentType":employmentType,
        "experienceLevel":experienceLevel,

      };
      print("Data $data");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/jobPreferences",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> rawJobPreferences= Map<String, dynamic>.from(response.data['jobPreferences']);

        print("rawJobPreferences $rawJobPreferences");

        return JobPreferences.fromJson(rawJobPreferences ?? {});
      } else {
        throw Exception("Failed to Update Job Preferences");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<String>> updateSkills(List<String>? skills) async {
    try {
      print("updateSkills");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'skills':skills,
      };

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/skills",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data['skills']);
      } else {
        throw Exception("Failed to Update Skills");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Education> addEducation({
    required String? course,
    required String? specialization,
    required String? institution,
    required DateTime? startingYear,
    required DateTime? passingYear,
    required String? CGPA,
  }) async {
    try {
      print("addEducation");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'course': course,
        'specialization': specialization,
        'institution': institution,
        'startingYear': startingYear?.toIso8601String(),
        'passingYear': passingYear!=null ? passingYear.toIso8601String() :"",
        'CGPA': CGPA,
      };

      print("Data $data");
      final response = await dio.post(
        "${AppConstants.baseUrl}/candidate/education/add",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {

        print(response.data['educations'].last);

        Map<String,dynamic> rawAddedEducation =  Map<String, dynamic>.from(response.data['educations'].last);

        print("rawAdded Education $rawAddedEducation");

        Education education =  Education.fromJson(rawAddedEducation);

        print("After Parsing education $education");

        return education;
      } else {
        throw Exception("Failed to Add Education");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Network ERror $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("error------------------------------------- $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Education> updateEducation({
    required String? id,
    required String? course,
    required String? specialization,
    required String? institution,
    required DateTime? startingYear,
    required DateTime? passingYear,
    required String? CGPA,
  }) async {
    try {
      print("updateEducation");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'educationId': id,
        'course': course,
        'specialization': specialization,
        'institution': institution,
        'startingYear': startingYear?.toIso8601String(),
        'passingYear': passingYear!=null ? passingYear.toIso8601String() :"",
        'CGPA': CGPA,
      };

      if (id == null || id.isEmpty) {
        throw Exception("Education ID is required");
      }

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/education",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> updatedEducation = Map<String, dynamic>.from(response.data['education'].last);

        Education education = Education.fromJson(updatedEducation);
        return education;
      } else {
        throw Exception("Failed to Update Education");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> deleteEducation(String? id) async {
    try {
      print("deleteEducation");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      if (id == null || id.isEmpty) {
        throw Exception("Education ID is required");
      }

      final response = await dio.delete(
        "${AppConstants.baseUrl}/candidate/delete/education/$id",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to Delete Education");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<WorkExperience> addWorkExperience({
    required String? company,
    required String? position,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? descriptions,
  }) async {
    try {
      print("addWorkExperience");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'company': company,
        'position': position,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate !=null ? endDate.toIso8601String() : "",
        'descriptions': descriptions,
      };

      final response = await dio.post(
        "${AppConstants.baseUrl}/candidate/workExperience/add",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {

        Map<String,dynamic> rawWorkExperience = Map<String, dynamic>.from(response.data['workExperiences'].last);

        WorkExperience workExperience= WorkExperience.fromJson(rawWorkExperience);

        return workExperience;
      } else {
        throw Exception("Failed to Add Work Experience");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("error ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("error $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("error $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<WorkExperience> updateWorkExperience({
    required String? id,
    required String? company,
    required String? position,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? descriptions,
  }) async {
    try {
      print("updateWorkExperience");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'experienceId': id,
        'company': company,
        'position': position,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate !=null ? endDate.toIso8601String() : "",
        'descriptions': descriptions,
      };

      if (id == null || id.isEmpty) {
        throw Exception("Work Experience ID is required");
      }

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/workExperience",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> rawWorkEducation = Map<String, dynamic>.from(response.data['workExperience'].last);
        return  WorkExperience.fromJson(rawWorkEducation);
      } else {
        throw Exception("Failed to Update Work Experience");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> deleteWorkExperience(String? id) async {
    try {
      print("deleteWorkExperience");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      if (id == null || id.isEmpty) {
        throw Exception("Work Experience ID is required");
      }

      final response = await dio.delete(
        "${AppConstants.baseUrl}/candidate/delete/workExperience/$id",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to Delete Work Experience");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("error ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print(" Network Error $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Error $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Internship> addInternship({
    required String? company,
    required String? role,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? projectName,
    required List<String>? skills,
    required String? descriptions,
    required String? projectUrl,
  }) async {
    try {
      print("addInternship");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'company': company,
        'role': role,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate !=null ? endDate.toIso8601String() : "",
        'projectName': projectName,
        'skills': skills,
        'descriptions': descriptions,
        'projectUrl': projectUrl,
      };

      final response = await dio.post(
        "${AppConstants.baseUrl}/candidate/internship/add",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {

        Map<String, dynamic> rawInternShips= Map<String, dynamic>.from(response.data['internships'].last);

        return Internship.fromJson(rawInternShips);
      } else {
        throw Exception("Failed to Add Internship");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Internship> updateInternship({
    required String? id,
    required String? company,
    required String? role,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? projectName,
    required List<String>? skills,
    required String? descriptions,
    required String? projectUrl,
  }) async {
    try {
      print("updateInternship");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'internshipId': id,
        'company': company,
        'role': role,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate !=null ? endDate.toIso8601String() : "",
        'projectName': projectName,
        'skills': skills?.join(','),
        'descriptions': descriptions,
        'projectUrl': projectUrl,
      };

      print("Data $data");
      if (id == null || id.isEmpty) {
        throw Exception("Internship ID is required");
      }

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/internship",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        Map<String,dynamic> rawInternships= Map<String, dynamic>.from(response.data['internships'].last);
        return Internship.fromJson(rawInternships);
      } else {
        throw Exception("Failed to Update Internship");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> deleteInternship(String? id) async {
    try {
      print("deleteInternship");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      if (id == null || id.isEmpty) {
        throw Exception("Internship ID is required");
      }

      final response = await dio.delete(
        "${AppConstants.baseUrl}/candidate/delete/internship/$id",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to Delete Internship");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Project> addProject({
    required String? projectName,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? descriptions,
    required List<String>? skills,
    required String? projectUrl,
  }) async {
    try {
      print("addProject");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'projectName': projectName,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate !=null ? endDate.toIso8601String() : "",
        'descriptions': descriptions,
        'skills': skills,
        'projectUrl': projectUrl,
      };

      final response = await dio.post(
        "${AppConstants.baseUrl}/candidate/project/add",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String,dynamic> rawProjects=Map<String, dynamic>.from(response.data['projects'].last);
        return Project.fromJson(rawProjects);
      } else {
        throw Exception("Failed to Add Project");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error dio ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Network Error $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print(" Error $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Project> updateProject({
    required String? id,
    required String? projectName,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? descriptions,
    required List<String>? skills,
    required String? projectUrl,
  }) async {
    try {
      print("updateProject");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      Map<String,dynamic> data = {
        'projectId': id,
        'projectName': projectName,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate !=null ? endDate.toIso8601String() : "",
        'descriptions': descriptions,
        'skills': skills,
        'projectUrl': projectUrl,
      };

      if (id == null || id.isEmpty) {
        throw Exception("Project ID is required");
      }

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/project",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {

        Map<String, dynamic> rawProject=Map<String, dynamic>.from(response.data['projects'].last);
        return Project.fromJson(rawProject);
      } else {
        throw Exception("Failed to Update Project");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Network Error $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Error $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> deleteProject(String? id) async {
    try {
      print("deleteProject");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      if (id == null || id.isEmpty) {
        throw Exception("Project ID is required");
      }

      final response = await dio.delete(
        "${AppConstants.baseUrl}/candidate/delete/project/$id",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to Delete Project");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Certification> addCertification({
    required String? name,
    required String? issuingOrganization,
    required DateTime? issueDate,
    required String? credentialID,
    required String? url,

  }) async {
    try {
      print("addCertification");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      final data = {
        'name': name,
        'issuingOrganization': issuingOrganization,
        'issueDate': issueDate?.toIso8601String(),
        'credentialID': credentialID,
        'url': url,
      };

      final response = await dio.post(
        "${AppConstants.baseUrl}/candidate/certification/add",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("201 Resone");
        Map<String, dynamic> rawCertifications=Map<String, dynamic>.from(response.data['certifications'].last);
        return Certification.fromJson(rawCertifications);
      } else {
        throw Exception("Failed to Add Certification");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error dio ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Network Eror $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("unexpected Eror $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Certification> updateCertification({
    required String? id,
    required String? name,
    required String? issuingOrganization,
    required DateTime? issueDate,
    required String? credentialID,
    required String? url,
  }) async {
    try {
      print("updateCertification");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      final data = {
        'certificationId': id,
        'name': name,
        'issuingOrganization': issuingOrganization,
        'issueDate': issueDate?.toIso8601String(),
        'credentialID': credentialID,
        'url': url,
      };

      if (id == null || id.isEmpty) {
        throw Exception("Certification ID is required");
      }

      final response = await dio.put(
        "${AppConstants.baseUrl}/candidate/update/certification",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> rawCertifications= Map<String, dynamic>.from(response.data['certifications'].last);

        return Certification.fromJson(rawCertifications);
      } else {
        throw Exception("Failed to Update Certification");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error dio ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Network Eror $e");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("unexpected Eror $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> deleteCertification(String? id) async {
    try {
      print("deleteCertification");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      if (id == null || id.isEmpty) {
        throw Exception("Certification ID is required");
      }

      final response = await dio.delete(
        "${AppConstants.baseUrl}/candidate/delete/certification/$id",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to Delete Certification");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> updateResume() async {
    try {
      print("deleteResume");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      final response = await dio.delete(
        "${AppConstants.baseUrl}/candidate/resume/delete",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.statusCode == 200) {
        return response.data['updatedUser']['resume'] as String?;
      } else {
        throw Exception("Failed to Delete Resume");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}