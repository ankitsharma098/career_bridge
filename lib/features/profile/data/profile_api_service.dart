

import 'dart:io';

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class EmployerProfileService{


  final dio = Dio();

  Future<void> updatePersonalInfo({ required String? fullName,
      required File? profilePicFile,
    required String? email,
    required String? phoneNumber,
    required String? address,
    required String? DOB,
    required String? designation,
    required String? gender}) async {
    try {
      print("updatePersonalInfo");

      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken!.isEmpty) {
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
      addIfValid('designation', designation);
      addIfValid('gender', gender);

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
                    filename: 'profile.$extension',
                    contentType: MediaType.parse(mimeType)
                )
            )
        );
      }

      print("APi hit data $formData");
      final response = await dio.put(
        "${AppConstants.baseUrl}/employer/update/personalInfo",
        options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            },
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
        final updatedUser = response.data['updatedUser'];

        print("Response $updatedUser");
        await HiveUtils.updateEmployerData(updatedUser);


        return updatedUser;
      }
    } on DioException catch (e) {
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

  Future<void> updateAboutSection(String about) async{
    try{

      String? accessToken= await HiveUtils.getAccessToken();
      if(accessToken==null || accessToken.isEmpty){
        throw Exception("Access Token not found");

      }
      final response =await dio.put( "${AppConstants.baseUrl}/employer/update/about",
      options: Options(
        headers: {
          'Authorization' :'Bearer $accessToken'
        }
      ),
        data: {
        'about':about
        }
      );
      if (response.statusCode == 200) {
        final updatedUser = response.data['updatedUser'];

        print("Response $updatedUser");
        await HiveUtils.updateEmployerData(updatedUser);
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
