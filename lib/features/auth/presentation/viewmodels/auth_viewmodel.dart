// lib/features/auth/presentation/viewmodels/auth_viewmodel.dart
import 'dart:async';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final User? user; // Use User object instead of boolean
  final bool isAuthenticated; // Computed property

  AuthState({this.isLoading = false, this.error, this.user})
    : isAuthenticated = user != null;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    bool resetUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: resetUser ? null : (user ?? this.user),
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authStateSubscription;

  AuthViewModel(this._repository) : super(AuthState()) {
    // Listen to authentication state changes
    _authStateSubscription = _repository.authStateChanges().listen((user) {
      print('Auth state changed: ${user?.email}');
      print('User is now: ${user != null ? "Logged in" : "Logged out"}');

      // PROPERLY update the state with the new user
      state = AuthState(
        isLoading:
            false, // Always set loading to false when we get a stream update
        error: null, // Clear any errors
        user: user, // Set the new user (could be null)
      );
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithGoogle();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Future<void> signInWithFacebook() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   try {
  //     await _repository.signInWithFacebook();
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //     rethrow;
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }
  // Future<void> signInWithFacebook() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   try {
  //     final result = await _repository.signInWithFacebook();
  //     // Update state with the new user only
  //     state = state.copyWith(user: result); // <-- isAuthenticated is computed
  //   } catch (e) {
  //     state = state.copyWith(error: e.toString());
  //     rethrow;
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }
  // Future<User?> signInWithFacebook() async {
  //   final LoginResult loginResult = await FacebookAuth.instance.login(
  //     permissions: ['public_profile', 'email'],
  //   );
  //
  //   if (loginResult.status == LoginStatus.success) {
  //     final userData = await FacebookAuth.instance.getUserData();
  //
  //     final email = userData['email'] as String?;
  //     final name = userData['name'] as String?;
  //     final id = userData['id'] as String?;
  //
  //     // Use Firebase Auth with Facebook credential
  //     final facebookAuthCredential = FacebookAuthProvider.credential(
  //       loginResult.accessToken!.tokenString,
  //     );
  //
  //     final userCredential = await FirebaseAuth.instance.signInWithCredential(
  //       facebookAuthCredential,
  //     );
  //
  //     // Optionally update Firestore with fallback values
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userCredential.user!.uid)
  //         .set({
  //           'email': email ?? '${id}@facebook.com', // fallback if null
  //           'displayName': name ?? 'Facebook User',
  //           'createdAt': FieldValue.serverTimestamp(),
  //         }, SetOptions(merge: true));
  //
  //     return userCredential.user;
  //   } else {
  //     throw Exception(
  //       'Facebook sign in failed: ${loginResult.status} - ${loginResult.message}',
  //     );
  //   }
  // }
  Future<User?> signInWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (loginResult.status == LoginStatus.success) {
        final facebookAuthCredential = FacebookAuthProvider.credential(
          loginResult.accessToken!.tokenString,
        );

        // Attempt to sign in with the Facebook credential
        return (await FirebaseAuth.instance.signInWithCredential(
          facebookAuthCredential,
        )).user;
      } else {
        throw Exception('Facebook sign in failed: ${loginResult.status}');
      }
    } on FirebaseAuthException catch (e) {
      // Check for the specific error when an account exists with a different provider
      if (e.code == 'account-exists-with-different-credential') {
        final pendingCred = e.credential;
        final email = e.email;

        // In a provider-first flow, you would not know the old provider.
        // For this example, we assume the only other provider is Google.
        // You would need to handle this with a clear UI flow in a real app.
        print(
          'An account with the email $email already exists. Please sign in with Google first.',
        );

        try {
          // Sign the user in with the existing Google account
          final googleUser = await GoogleSignIn().signIn();
          final googleAuth = await googleUser!.authentication;
          final googleCred = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(googleCred);

          // Link the pending Facebook credential to the existing Google account
          await userCredential.user!.linkWithCredential(pendingCred!);
          return userCredential.user;
        } on Exception catch (innerException) {
          // Handle potential errors during the linking process
          print('Error during account linking: $innerException');
          rethrow;
        }
      } else {
        // Re-throw any other FirebaseAuthException
        rethrow;
      }
    } on Exception {
      rethrow;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithEmail(email, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signUpWithEmail(email, password);

      if (user != null) {
        await _createUserDocument(user.uid, email, username);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _createUserDocument(
    String uid,
    String email,
    String username,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': email,
        'displayName': username,
        'username': username,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'totalGames': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<void> signOut() async {
    // Set loading to true
    state = AuthState(isLoading: true, user: state.user);

    try {
      await _repository.signOut();
      print('Sign out successful in ViewModel');

      // DON'T manually update state here - let the stream handle it
      // The stream will emit null and update the state automatically
    } catch (e) {
      // On error, update state with error but keep the current user
      state = AuthState(
        isLoading: false,
        error: e.toString(),
        user: state.user,
      );
      print('Sign out error in ViewModel: $e');
      rethrow;
    }
  }

  void clearUser() {
    state = state.copyWith(user: null, isLoading: false, error: null);
  }
}
