

import 'package:android/data/models/employer/employer_model.dart';
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
      print("accession stored");
      await box.put("employer", data["employer"]);
      print("employer data ${data['employer'].runtimeType}");
      print("company data ${data['companyDetails'].runtimeType}");
      await box.put("companyDetails", data["companyDetails"]);

      await box.put("isLoggedIn", true);


    }catch(e){
      print('Error storing user data: $e');
      throw Exception('Failed to store user data');
    }
  }

  static Future<Map<String, dynamic>> getEmployerData() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      dynamic rawEmployer = box.get('employer');

      // Aggressive type conversion
      Map<String, dynamic> employer = {};

      if (rawEmployer is Map) {
        // Deep conversion of nested maps
        employer = _deepConvertMap(rawEmployer);
      }

      print('Employer Data Retrieved: $employer');
      print('rawEmployer Data Type: ${rawEmployer.runtimeType}');

      return employer;
    } catch (e) {
      print('Detailed Error getting Employer data: $e');
      return {};
    }
  }

  static Future<void> updateEmployerData(Map<String, dynamic> updatedUser) async {
    try{

      final box=await Hive.openBox(USER_BOX);
      Map<String,dynamic> currentEmployerData = await getEmployerData();
      if (updatedUser['personalInfo'] != null) {
        currentEmployerData['personalInfo'] ??= {};

        final personalInfo = updatedUser['personalInfo'];
        if (personalInfo['fullName'] != null) {
          currentEmployerData['personalInfo']['fullName'] = personalInfo['fullName'];
        }
        if (personalInfo['email'] != null) {
          currentEmployerData['personalInfo']['email'] = personalInfo['email'];
        }
        if (personalInfo['phoneNumber'] != null) {
          currentEmployerData['personalInfo']['phoneNumber'] = personalInfo['phoneNumber'];
        }
        if (personalInfo['profilePic'] != null) {
          currentEmployerData['personalInfo']['profilePic'] = personalInfo['profilePic'];
        }
      }

      if (updatedUser['companyDetails'] != null) {
        currentEmployerData['companyDetails'] ??= {};

        final companyDetails = updatedUser['companyDetails'];
        if (companyDetails['designation'] != null) {
          currentEmployerData['companyDetails']['designation'] = companyDetails['designation'];
        }
      }
      await box.put('employer', currentEmployerData);

    }catch(e){
      print('Error updating employer data: $e');
      throw Exception('Failed to update employer data');
    }
  }


  static Map<String, dynamic> _deepConvertMap(Map rawMap) {
    Map<String, dynamic> convertedMap = {};

    rawMap.forEach((key, value) {
      // Convert key to string
      String stringKey = key.toString();

      // Handle nested structures
      if (value is Map) {
        convertedMap[stringKey] = _deepConvertMap(value);
      } else if (value is List) {
        convertedMap[stringKey] = value.map((item) =>
        item is Map ? _deepConvertMap(item) : item
        ).toList();
      } else {
        convertedMap[stringKey] = value;
      }
    });

    return convertedMap;
  }


  static Future<Map<String,dynamic>> getCompanyData() async{
    try{
      final box=await Hive.openBox(USER_BOX);
      dynamic rawCompanyDetails= await box.get('companyDetails');
      Map<String, dynamic> company = {};

      if (rawCompanyDetails is Map) {
        // Deep conversion of nested maps
        company = _deepConvertMap(rawCompanyDetails);
      }
      print('rawCompanyDetails data type: ${company.runtimeType}');

      return company;
    }catch(e){
      print('Error getting Company data: $e');
      return {};
    }
  }


  static Future<String?> getAccessToken() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      final accessToken = await box.get('accessToken');
      return accessToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      final refreshToken =await box.get('refreshToken');
      return refreshToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  static Future<bool> getLoggedIn() async {
    try {
      final box = await Hive.openBox(USER_BOX);
      bool isLoggedIn =await box.get('isLoggedIn') ?? false;
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