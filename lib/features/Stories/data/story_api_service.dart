

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/data/models/Job/job_model.dart';
import 'package:android/data/models/application/application_model.dart';
import 'package:android/data/models/story/story_model.dart';
import 'package:dio/dio.dart';

class StoryApiService {

  final dio = Dio()
    ..options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
      validateStatus: (status) => status! < 500,
    )
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));


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

       // Map<String,dynamic> pagination=Map<String,dynamic>.from(response.data['pagination']);



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

  Future<StoryModel> createStory(Map<String,dynamic> story)async{

    try{

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }

      print("createStory api");


      FormData formData = FormData.fromMap({
        "title":story["title"],
        'content':story['content'],
        'category':story['category'],
        'tags':story['tags'],
      });

      List<String> imagePaths=story['images'] ?? [];
      if (imagePaths.length > 5) {
        throw Exception("Maximum 5 files allowed");
      }

      for(int i=0;i<imagePaths.length;i++){
        String extension = imagePaths[i].split('.').last;
        formData.files.add(MapEntry('media', await MultipartFile.fromFile(imagePaths[i],  filename: 'file$i.$extension')));
      }
      print("formData $formData");

      final response = await dio.post('${AppConstants.baseUrl}/stories/create',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken',
             // 'Content-Type': 'multipart/form-data',
            },

        ),
          onSendProgress: (sent, total) {
            final progress = (sent / total * 100).toStringAsFixed(2);
            print('Upload Progress---------------------------------------: $progress%');
          },
        data: formData
      );

      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 201) {

        Map<String,dynamic> rawStory=Map<String,dynamic>.from(response.data['story']);

        StoryModel story = StoryModel.fromJson(rawStory);

        print("stories $rawStory");
        return story;
      }else{
        throw Exception('Failed to create a story  ${response.statusMessage}');
      }


    }on DioException catch (e) {
      print("DioException details:");
      print("Status code: ${e.response?.statusCode}");
      print("Error response: ${e.response?.data}");
      print("Error type: ${e.type}");
      print("Error message: ${e.message}");
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