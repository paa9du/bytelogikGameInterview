// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    FirebaseAuth.instance,
    GoogleSignIn(
      scopes: ['email', 'profile'],
      signInOption: SignInOption.standard,
    ),
    FacebookAuth.instance,
  );
});

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<User?> signInWithFacebook();
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Stream<User?> authStateChanges();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthRepositoryImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._facebookAuth,
  );

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        // Debug: check all available properties
        final accessToken = result.accessToken!;
        print('AccessToken type: ${accessToken.runtimeType}');
        print('AccessToken: $accessToken');

        // Try to serialize to JSON to see all properties
        final json = accessToken.toJson();
        print('AccessToken JSON: $json');

        // Use the correct property based on what you see in the JSON
        final String accessTokenString = json['token'] ?? json['accessToken'];

        final AuthCredential credential = FacebookAuthProvider.credential(
          accessTokenString,
        );

        final UserCredential userCredential = await _firebaseAuth
            .signInWithCredential(credential);

        return userCredential.user;
      } else if (result.status == LoginStatus.cancelled) {
        return null;
      } else {
        throw Exception('Facebook login failed: ${result.status}');
      }
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Email sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Email sign in failed: $e');
    }
  }

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Email sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Email sign up failed: $e');
    }
  }

  // lib/features/auth/data/repositories/auth_repository_impl.dart
  @override
  Future<void> signOut() async {
    try {
      print('Starting sign out process...');

      // Sign out from Google
      try {
        await _googleSignIn.signOut();
        print('Google sign out successful');
      } catch (e) {
        print('Google sign out failed (but continuing): $e');
      }

      // Sign out from Facebook (now should work with proper configuration)
      try {
        await _facebookAuth.logOut();
        print('Facebook sign out successful');
      } catch (e) {
        print('Facebook sign out failed (but continuing): $e');
        // Continue with other sign-out operations
      }

      // Most important: Sign out from Firebase
      await _firebaseAuth.signOut();
      print('Firebase sign out successful');

      print('All sign out operations completed');
    } catch (e) {
      print('Sign out failed: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
}
