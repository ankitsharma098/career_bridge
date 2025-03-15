

import 'package:android/data/models/Job/job_model.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/hiveUtils.dart';
import '../model/candidate_job_model.dart';

class CandidateJobServices {
  final dio = Dio();
  Future<List<CandidateJobModel>> fetchRecommendedJobs(int page) async{

    try{
      print("fetchRecommendedJobs api");

      String? accessToken = await HiveUtils.getAccessToken();

      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('${AppConstants.baseUrl}/candidate/jobs-recommended?page=$page',
        options:  Options(
            headers: {
              'Authorization':'Bearer $accessToken'
            }
        ),
      );

      if (response.statusCode == 200) {

        List<Map<String,dynamic>> rawRecommendedJobs=List<Map<String,dynamic>>.from(response.data['jobs']);

        print("raw response $rawRecommendedJobs");
        List<CandidateJobModel> recommendedJobs = rawRecommendedJobs
            .map((json) => CandidateJobModel.fromJson(json))
            .toList();

        print("recommendedJobs $recommendedJobs");
        return recommendedJobs;
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

  Future<List<CandidateJobModel>> fetchSearchedJobs({
    required int page,
    int limit = 10,
    String? search,
  }) async {
    try {
      print("fetchSearchedJobs API called with page: $page");

      String? accessToken = await HiveUtils.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Access token not found");
      }

      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'search': search,
      };

      final response = await dio.get(
        '${AppConstants.baseUrl}/candidate/jobs-search/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        // Type-safe extraction of jobs from response
        final responseData = response.data as Map<String, dynamic>;
        final rawSearchedJobs = List<Map<String, dynamic>>.from(responseData['jobs'] ?? []);

        print("Raw response jobs: $rawSearchedJobs");

        final searchedJobs = rawSearchedJobs.map((json) => CandidateJobModel.fromJson(json)).toList();

        print("Parsed searched jobs: $searchedJobs");

        final pagination = responseData['pagination'] as Map<String, dynamic>?;

        if (pagination != null) {
          print("Pagination info: Current Page: ${pagination['currentPage']}, Total Pages: ${pagination['totalPages']}");
        }

        return searchedJobs;
      } else {
        print("Error response: ${response.statusCode} - ${response.statusMessage}");
        throw Exception('Failed to load jobs: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'An error occurred';
        print("Dio error: $errorMessage");
        throw Exception(errorMessage);
      } else {
        print("Network error: ${e.message}");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }


}