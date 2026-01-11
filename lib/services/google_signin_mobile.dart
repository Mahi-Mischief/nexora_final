import 'package:google_sign_in/google_sign_in.dart';

/// Returns a map with keys `accessToken` and `idToken`, or null if cancelled.
Future<Map<String, String>?> getGoogleAuthTokens() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null;
  final googleAuth = await googleUser.authentication;
  return {
    'accessToken': googleAuth.accessToken ?? '',
    'idToken': googleAuth.idToken ?? '',
  };
}
