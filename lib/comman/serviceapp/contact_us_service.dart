import 'package:aiimagegenerator2/comman/serviceapp/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsService {
  static final String _supportEmail = 'sk1992601@gmail.com';
  static final String _subject = Uri.encodeComponent('App Support Request');
  static final String _body = Uri.encodeComponent('Hi,\n\nI need help with...');

  static Future<void> launchEmail() async {
    final Uri emailUri = Uri.parse('mailto:$_supportEmail?subject=$_subject&body=$_body');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ToastService.showToast(message: "No email app available.");
    }
  }
}
