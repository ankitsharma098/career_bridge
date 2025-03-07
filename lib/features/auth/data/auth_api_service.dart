

import 'dart:convert';
import 'dart:io';

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../data/models/company/company_model.dart';
import '../../../data/models/employer/employer_model.dart';

class AuthApiServices {

  final dio = Dio();

//Employer Side APIs


  Future<void> employerLogin(String email, String password) async {


    try{
      final response = await dio.post("${AppConstants.baseUrl}/employer/login",

        data: {
        "email":email,
          "password":password
        },

      );
      if(response.statusCode==200){
        print("Full Response: ${jsonEncode(response.data)}");

        final employerData = Map<String, dynamic>.from(response.data['user']);

        final companyData = Map<String,dynamic>.from(response.data["companyDetails"]);
        final tokens = response.data["tokens"] as Map<String,dynamic>;



        // final employerResponse = Employer.fromJson(employerData);
        // final companyResponse = CompanyDetails.fromJson(companyData);

        print("////employer runtimeType ${companyData.runtimeType}");
        print("////companyDetails runtimeType ${employerData.runtimeType}");
        Map<String,dynamic> data={
          "employer": employerData,
          "companyDetails": companyData,
          'accessToken':tokens['accessTokens'],
          'refreshToken':tokens['refreshToken'],
        };
        await HiveUtils.storeEmployerData(data);

      }

    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> saveToken(String fcmToken) async{
    try{
      print("tokens saved-------");
      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.post("${AppConstants.baseUrl}/notification/save-token",
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
        data: {
          "fcmToken":fcmToken,
        },

      );
      if(response.statusCode==200) {
        print("tokens saved-------");
        bool isSavedFcmToken = response.data['status'] ?? false;
        print("isSavedToken $isSavedFcmToken");
      }

    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>> checkCompany(String email, String companyName) async {
    try {
      final response = await dio.post(
        "${AppConstants.baseUrl}/employer/check-company", // Adjust endpoint as needed
        data: {
          "email": email,
          "companyName": companyName,
        },
      );

      if (response.statusCode == 200) {
        return {'exists': false};
      } else if (response.statusCode == 409) {
        return {
          'exists': true,
          'message': response.data['message'] ?? 'Company already registered',
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to check company');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
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

  Future<void> sendOtp(String email) async {
    try {
      final response = await dio.post(
        "${AppConstants.baseUrl}/otp/send", // Adjust endpoint as needed
        data: {"email": email},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }


  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await dio.post(
        "${AppConstants.baseUrl}/otp/verify", // Adjust endpoint as needed
        data: {
          "email": email,
          "otp": otp,
        },
      );

      if (response.statusCode == 200) {
        return response.data['token']; // Assuming backend returns a token
      } else {
        throw Exception(response.data['error'] ?? 'Invalid OTP');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> completeRegistration({
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> employerData,
    required Map<String, dynamic> documentUrls,
    required String verificationToken,
  }) async {
    try {
      final response = await dio.post(
        "${AppConstants.baseUrl}/employer/complete-registration",
        data: {
          "companyData": companyData,
          "employerData": employerData,
          "documentUrls": documentUrls,
          "verificationToken": verificationToken,
        },
      );

      if (response.statusCode == 201) {
        // Optionally store data in Hive if needed
        return;
      } else {
        throw Exception(response.data['error'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        throw Exception('Network error occurred');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }





  //Candidate side apis

  Future<void> candidateLogin(String email, String password) async {


    try{
      final response = await dio.post("${AppConstants.baseUrl}/candidate/login",

        data: {
          "email":email,
          "password":password
        },

      );
      if(response.statusCode==200){
        print("Full Response: ${jsonEncode(response.data)}");

        final candidateData = Map<String, dynamic>.from(response.data['user']);

        Map<String, String> tokens = Map<String, String>.from(response.data['tokens']);


        print("////candidateData tokens ${tokens}");
        Map<String,dynamic> data={
          "candidate": candidateData,
          'accessToken':tokens['accessToken'],
          'refreshToken':tokens['refreshToken'],
        };

        print("data $data");
        await HiveUtils.storeCandidateData(data);

      }

    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }
}