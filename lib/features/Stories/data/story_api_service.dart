

import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/data/models/Job/job_model.dart';
import 'package:android/data/models/application/application_model.dart';
import 'package:android/data/models/story/story_model.dart';
import 'package:dio/dio.dart';

class StoryApiService {

  final dio= Dio();
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

}