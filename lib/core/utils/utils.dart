

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveUtils {
  static const String USER_BOX = 'user_box';

  static Future<void> initHive() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }

  static Future<void> storeUserData(Map<String,dynamic> data) async {

    try{

      final box = await Hive.openBox(USER_BOX);
      print("Box opened");
      await box.put("accessToken", data["accessToken"]);
      await box.put("refreshToken", data["refreshToken"]);
      print("accestoken stored");
      print("data $data");
      await box.put("employer", data["employer"]);
      await box.put("CompanyDetails", data["companyDetails"]);

      await box.put("isLoggedIn", true);


    }catch(e){
      print('Error storing user data: $e');
      throw Exception('Failed to store user data');
    }
  }

  static Future<Map<String,dynamic>?> getEmployerData() async{
    try{
      final box=await Hive.openBox(USER_BOX);
      return box.get("employer");
  }catch(e){
      print('Error getting Employer data: $e');
      return null;
    }
    }
  static Future<Map<String,dynamic>?> getCompanyData() async{
    try{
      final box=await Hive.openBox(USER_BOX);
      return box.get("companyDetails");
    }catch(e){
      print('Error getting Company data: $e');
      return null;
    }
  }


  static Future<String?> getAccessToken() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      final accessToken = box.get('accessToken');
      return accessToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      final refreshToken = box.get('refreshToken');
      return refreshToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  static Future<bool> getLoggedIn() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      bool isLoggedIn = box.get('isLoggedIn') ?? false;
      return isLoggedIn;
    } catch (e) {
      print('Error getting isLoggedIn: $e');
      return false;
    }
  }

  static Future<void> clearUserData() async {
    try{
      final box = await Hive.openBox(USER_BOX);
      await box.clear();
    }catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data');
    }
  }


}