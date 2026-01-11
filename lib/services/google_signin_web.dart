import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Web implementation: perform Firebase popup sign-in and return idToken.
Future<Map<String, String>?> getGoogleAuthTokens() async {
  final provider = fb.GoogleAuthProvider();
  final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(provider);
  final idToken = await userCredential.user?.getIdToken();
  if (idToken == null) return null;
  return {
    'idToken': idToken,
  };
}
