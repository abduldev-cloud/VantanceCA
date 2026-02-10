import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlService {
  static goToUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }


  static goToPurchase(){
    goToUrl(API.purchaseUrl);
  }

  static getCurrentUrl(){
    var path = Uri.base.path;
    return path.replaceAll('flatten/web/', '');
  }
}
