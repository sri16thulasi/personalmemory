import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Email & Password Sign-In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Email Sign-In Failed: $e");
      return null;
    }
  }

  // 🔹 Email & Password Sign-Up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Email Sign-Up Failed: $e");
      return null;
    }
  }

  // 🔹 Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } catch (e) {
      print("Password Reset Failed: $e");
    }
  }

  // 🔹 Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Failed: $e");
    }
  }

  /*
  // 🔹 Google Sign-In (Uncomment and add 'google_sign_in' package to pubspec.yaml)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google Login Failed: $e");
      return null;
    }
  }

  // 🔹 Facebook Sign-In (Uncomment and add 'flutter_facebook_auth' package to pubspec.yaml)
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) {
          print("Facebook login failed: Access token is null");
          return null;
        }

        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        print("Facebook login failed: ${result.message}");
        return null;
      }
    } catch (e) {
      print("Facebook Login Failed: $e");
      return null;
    }
  }

  // 🔹 Twitter Sign-In (Uncomment and configure Twitter in Firebase Console)
  Future<User?> signInWithTwitter() async {
    try {
      TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      UserCredential userCredential = await _auth.signInWithProvider(twitterProvider);
      return userCredential.user;
    } catch (e) {
      print("Twitter Login Failed: $e");
      return null;
    }
  }
  */
}