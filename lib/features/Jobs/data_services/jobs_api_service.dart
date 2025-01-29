

import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';

class JobApiService {
  
  final dio= Dio();
  Future<Map<String,dynamic>> fetchJobStats() async{
    
    try{
      
      String? accessToken = await HiveUtils.getAccessToken();
      
      if(accessToken==null || accessToken.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get('http://13.60.19.132:8000/employer/job-stats',
      options:  Options(
        headers: {
          'Authorization':'Bearer $accessToken'
        }
      ),
      );

      if (response.statusCode == 200) {
        final rawStats = response.data['stats'];

        Map<String,dynamic> stats=Map<String,dynamic>.from(rawStats);

        print("JobStats $stats");
       return stats;
      }else{
        throw Exception('Failed to Load Stats ${response.statusMessage}');
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