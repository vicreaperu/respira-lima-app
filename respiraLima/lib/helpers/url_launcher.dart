import 'package:url_launcher/url_launcher.dart';
Future<void> launchUrlCall(String urlName) async {
  final Uri _url = Uri.parse(urlName);
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
}