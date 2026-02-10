import 'package:binary_success/helpers/network/api_service.dart';

class OnboardingServices {
  Future<dynamic> getOnboardingSchoolDetails(String inviteCode) async {
    try {
      final response = await APIService.get(
        path: '/users/invite/$inviteCode',
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  //acceptSchoolInvite
  Future<dynamic> acceptSchoolInvite(
      String inviteCode, Map<String, dynamic> data) async {
    try {
      final response = await APIService.post(
        path: '/users/accept-invite/$inviteCode',
        mapData: data,
      );
      return response;
    } catch (e) {
      return null;
    }
  }
}
