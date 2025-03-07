
import 'package:android/core/constants/app_constants.dart';
import 'package:android/core/utils/hiveUtils.dart';
import 'package:dio/dio.dart';

class CandidateDashboardService{


  final dio = Dio();

  Future<Map<String,dynamic>> dashboardStats() async {

    try{
      String? accessToken= await HiveUtils.getAccessToken();
      if(accessToken!.isEmpty){
        throw Exception("AccessToken not found");
      }
      final response = await dio.get("${AppConstants.baseUrl}/candidate/dashboard-stats",
          options: Options(
              headers: {
                'Authorization':'Bearer $accessToken'
              }
          )
      );

      if(response.statusCode==200){
        Map<String,dynamic> candidateStats = Map<String,dynamic>.from(response.data["stats"]);

        return candidateStats;
      }else {
        throw Exception('Failed to Load Stats');
      }


    }catch(e){

      print("Error $e");
      throw Exception('Network Error $e');

    }


  }

}