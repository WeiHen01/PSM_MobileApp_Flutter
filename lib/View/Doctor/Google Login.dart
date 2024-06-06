import 'package:google_sign_in/google_sign_in.dart';

/**
 * Mandatory step for enabling Google Login
 * -> Make sure gradle-wrapper.properties compatible with your current Java JDK setup in environment variables 
 * -> Need to sign the app with cmd type "./gradlew signingReport" to get SHA-1 fingerprint certificate
 */
class GoogleLogin {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future logout() => _googleSignIn.disconnect();
}