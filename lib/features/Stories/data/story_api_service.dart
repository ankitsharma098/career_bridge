

import 'dart:io';
import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/data/models/story/story_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class StoryApiService {

  final dio = Dio();


  Future<List<StoryModel>> fetchStories(int page) async{

    try{
      print("fetchStories api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/stories/all?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        List<Map<String,dynamic>> rawStories=List<Map<String,dynamic>>.from(response.data['stories']);

        print("raw response $rawStories");
        List<StoryModel> stories = rawStories
            .map((json) => StoryModel.fromJson(json))
            .toList();

        print("stories $StoryModel");
        return stories;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to Load stories ${response.statusMessage}');
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

  Future<List<StoryModel>> fetchMyStories(int page) async{

    try{
      print("fetchMyStories api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/stories/myStories?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        List<Map<String,dynamic>> rawStories=List<Map<String,dynamic>>.from(response.data['myStories']);

        print("raw response $rawStories");
        List<StoryModel> stories = rawStories
            .map((json) => StoryModel.fromJson(json))
            .toList();

        print("stories $StoryModel");
        return stories;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to Load stories ${response.statusMessage}');
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
  Future<List<StoryModel>> fetchSavedStories(int page) async{

    try{
      print("fetchSavedStories api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/stories/savedStories?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        List<Map<String,dynamic>> rawStories=List<Map<String,dynamic>>.from(response.data['savedStories']);

        print("raw response $rawStories");
        List<StoryModel> stories = rawStories.map((json) => StoryModel.fromJson(json)).toList();

        print("stories $StoryModel");
        return stories;
      }else{
        print("Error->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${response}");
        throw Exception('Failed to Load stories ${response.statusMessage}');
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

  Future<Map<String,dynamic>> fetchStoriesStats() async {

    try{
      print("fetchStoriesStats api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/stories/stats',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        Map<String,dynamic> storiesStats=Map<String,dynamic>.from(response.data['stats']);


        print("stories $storiesStats");
        return storiesStats;
      }else{
        throw Exception('Failed to Load stories stats ${response.statusMessage}');
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

  Future<StoryModel> createStory(Map<String, dynamic> story) async {
    try {
      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      // Create form data with basic story information
      FormData formData = FormData.fromMap({
        "title": story["title"],
        'content': story['content'],
        'category': story['category'],
        'tags': story['tags'],
      });

      // Handle images
      List<String> imagePaths = story['images'] ?? [];
      if (imagePaths.length > 5) {
        throw Exception("Maximum 5 files allowed");
      }

      // Add files to form data with proper MIME type
      for (int i = 0; i < imagePaths.length; i++) {
        File imageFile = File(imagePaths[i]);
        if (!await imageFile.exists()) {
          throw Exception("Image file not found: ${imagePaths[i]}");
        }

        String extension = imagePaths[i].split('.').last.toLowerCase();
        String mimeType;

        // Set correct MIME type based on file extension
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'pdf':
            mimeType = 'application/pdf';
            break;
          case 'doc':
            mimeType = 'application/msword';
            break;
          case 'docx':
            mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            break;
          default:
            throw Exception('Unsupported file type: $extension');
        }

        formData.files.add(
            MapEntry('media',
                await MultipartFile.fromFile(
                    imagePaths[i],
                    filename: 'file$i.$extension',
                    contentType: MediaType.parse(mimeType)
                )
            )
        );
      }

      // Make the request with reasonable timeouts
      final response = await dio.post(
          '${AppConstants.baseUrl}/stories/create',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
            contentType: 'multipart/form-data',
          ),
          onSendProgress: (sent, total) {
            if (total != -1) {
              final progress = (sent / total * 100).toStringAsFixed(2);
              print('Upload Progress: $progress%');
            }
          },
          data: formData
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> rawStory = Map<String, dynamic>.from(response.data['story']);
        return StoryModel.fromJson(rawStory);
      } else {
        throw Exception('Failed to create story: ${response.statusMessage}');
      }

    } on DioException catch (e) {
      print("DioException details:");
      print("Status code: ${e.response?.statusCode}");
      print("Error response: ${e.response?.data}");
      print("Error type: ${e.type}");
      print("Error message: ${e.message}");

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Upload timed out. Please check your internet connection.');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An error occurred");
      } else {
        throw Exception('Network error occurred: ${e.message}');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }


  Future<StoryModel> updateStory(Map<String, dynamic> story,String storyId) async {
    try {
      String? accessToken = await HiveUtils.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("AccessToken not found");
      }

      // Create form data with basic story information
      FormData formData = FormData.fromMap({
        "title": story["title"],
        'content': story['content'],
        'category': story['category'],
        'keepMediaIds':story['keepMediaIds'],
        'tags': story['tags'],
      });


      print("story formData$formData");
      print("story $story");

      // Handle images
      List<String> imagePaths = story['images'] ?? [];
      if (imagePaths.length > 5) {
        throw Exception("Maximum 5 files allowed");
      }

      // Add files to form data with proper MIME type
      for (int i = 0; i < imagePaths.length; i++) {
        File imageFile = File(imagePaths[i]);
        if (!await imageFile.exists()) {
          throw Exception("Image file not found: ${imagePaths[i]}");
        }

        String extension = imagePaths[i].split('.').last.toLowerCase();
        String mimeType;

        // Set correct MIME type based on file extension
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'pdf':
            mimeType = 'application/pdf';
            break;
          case 'doc':
            mimeType = 'application/msword';
            break;
          case 'docx':
            mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            break;
          default:
            throw Exception('Unsupported file type: $extension');
        }

        formData.files.add(
            MapEntry('media',
                await MultipartFile.fromFile(
                    imagePaths[i],
                    filename: 'file$i.$extension',
                    contentType: MediaType.parse(mimeType)
                )
            )
        );
      }

      // Make the request with reasonable timeouts
      final response = await dio.put(
          '${AppConstants.baseUrl}/stories/update/$storyId',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
            contentType: 'multipart/form-data',
          ),
          onSendProgress: (sent, total) {
            if (total != -1) {
              final progress = (sent / total * 100).toStringAsFixed(2);
              print('Upload Progress: $progress%');
            }
          },
          data: formData
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> rawStory = Map<String, dynamic>.from(response.data['story']);
        return StoryModel.fromJson(rawStory);
      } else {
        throw Exception('Failed to update story: ${response.statusMessage}');
      }

    } on DioException catch (e) {
      print("DioException details:");
      print("Status code: ${e.response?.statusCode}");
      print("Error response: ${e.response?.data}");
      print("Error type: ${e.type}");
      print("Error message: ${e.message}");

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Upload timed out. Please check your internet connection.');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "An error occurred");
      } else {
        throw Exception('Network error occurred: ${e.message}');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

}