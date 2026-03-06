import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pcdoor/main.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  void _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> registrarUsuario(String nome, String email, String senha) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await _firestore.collection('usuarios').doc(credential.user!.uid).set({
        'nome': nome,
        'email': email,
      });
      await _auth.signOut();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (r) => false);
    } on FirebaseAuthException catch (e) {
      _tratarErroAuth(e);
    }
  }

  Future<void> registrarEstabelecimento(String nome, String email, String senha, String endereco, String tipo,) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await _firestore.collection('estabelecimentos').doc(credential.user!.uid).set({
        'nome': nome,
        'email': email,
        'endereco': endereco,
        'tipo': tipo,
      });
      await _auth.signOut();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (r) => false);
    } on FirebaseAuthException catch (e) {
      _tratarErroAuth(e);
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      _tratarErroAuth(e);
    }
  }

  Future<bool> verificaTipo() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final doc = await _firestore.collection('estabelecimentos').doc(user.uid).get();
    
    return doc.exists;
  }

  Future<void> logout() async {
    await _auth.signOut();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (r) => false);
  }

  void _tratarErroAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        throw AuthException('Esse email já está cadastrado!');
      case 'invalid-email':
        throw AuthException('Email inválido!');
      case 'weak-password':
        throw AuthException('Sua senha deve conter no mínimo 6 caracteres!');
      case 'wrong-password':
      case 'invalid-credential':
        throw AuthException('Email ou senha incorretos!');
      case 'user-not-found':
        throw AuthException('Este email não está cadastrado!');
      default:
        throw AuthException('Erro ao autenticar. Tente novamente.');
    }
  }
}