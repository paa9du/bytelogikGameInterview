// lib/features/auth/presentation/viewmodels/auth_viewmodel.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signInWithFacebook();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
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
