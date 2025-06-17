import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as Math;

class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;
  final bool isTherapist;
  final Map<String, dynamic>? therapistInfo;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
    this.isTherapist = false,
    this.therapistInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      'isTherapist': isTherapist,
      'therapistInfo': therapistInfo,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      photoUrl: map['photoUrl'],
      isTherapist: map['isTherapist'] ?? false,
      therapistInfo: map['therapistInfo'],
    );
  }

  factory AppUser.fromFirebaseUser(firebase_auth.User firebaseUser, {
    String? displayName,
    bool isTherapist = false,
    Map<String, dynamic>? therapistInfo,
  }) {
    return AppUser(
      id: firebaseUser.uid,
      name: displayName ?? firebaseUser.displayName ?? 'Usuario',
      email: firebaseUser.email ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      photoUrl: firebaseUser.photoURL,
      isTherapist: isTherapist,
      therapistInfo: therapistInfo,
    );
  }
}

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream del usuario actual
  Stream<AppUser?> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      // Obtener datos adicionales del usuario desde Firestore
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return AppUser.fromMap({
            'id': firebaseUser.uid,
            'name': userData['name'] ?? firebaseUser.displayName ?? 'Usuario',
            'email': firebaseUser.email ?? '',
            'createdAt': (userData['createdAt'] as Timestamp?)?.toDate().toIso8601String() 
                         ?? firebaseUser.metadata.creationTime?.toIso8601String() 
                         ?? DateTime.now().toIso8601String(),
            'photoUrl': userData['photoUrl'] ?? firebaseUser.photoURL,
            'isTherapist': userData['isTherapist'] ?? false,
            'therapistInfo': userData['therapistInfo'],
          });
        } else {
          // Si no existe en Firestore, crear el documento
          final appUser = AppUser.fromFirebaseUser(firebaseUser);
          await _createUserDocument(appUser);
          return appUser;
        }
      } catch (e) {
        // En caso de error, devolver usuario básico
        return AppUser.fromFirebaseUser(firebaseUser);
      }
    });
  }

  // Usuario actual sincrónico
  AppUser? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null 
        ? AppUser.fromFirebaseUser(firebaseUser)
        : null;
  }

  // Registrar con email y password
  Future<AppUser> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    bool isTherapist = false,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;
      
      // Actualizar el display name
      await firebaseUser.updateDisplayName(name);
      
      // Crear el objeto AppUser
      final appUser = AppUser.fromFirebaseUser(
        firebaseUser,
        displayName: name,
        isTherapist: isTherapist,
      );

      // Guardar datos adicionales en Firestore
      await _createUserDocument(appUser);

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Iniciar sesión con email y password
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;
      
      // Obtener datos del usuario desde Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return AppUser.fromMap({
          'id': firebaseUser.uid,
          'name': userData['name'] ?? firebaseUser.displayName ?? 'Usuario',
          'email': firebaseUser.email ?? '',
          'createdAt': (userData['createdAt'] as Timestamp?)?.toDate().toIso8601String() 
                       ?? firebaseUser.metadata.creationTime?.toIso8601String() 
                       ?? DateTime.now().toIso8601String(),
          'photoUrl': userData['photoUrl'] ?? firebaseUser.photoURL,
          'isTherapist': userData['isTherapist'] ?? false,
          'therapistInfo': userData['therapistInfo'],
        });
      } else {
        // Si no existe en Firestore, crear el documento
        final appUser = AppUser.fromFirebaseUser(firebaseUser);
        await _createUserDocument(appUser);
        return appUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Iniciar sesión con Google
  Future<AppUser> signInWithGoogle() async {
    try {
      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Inicio de sesión con Google cancelado');
      }

      // Obtener los detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear una nueva credencial
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Verificar si es un usuario nuevo o existente
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        // Usuario existente - obtener datos de Firestore
        final userData = userDoc.data()!;
        return AppUser.fromMap({
          'id': firebaseUser.uid,
          'name': userData['name'] ?? firebaseUser.displayName ?? 'Usuario',
          'email': firebaseUser.email ?? '',
          'createdAt': (userData['createdAt'] as Timestamp?)?.toDate().toIso8601String() 
                       ?? firebaseUser.metadata.creationTime?.toIso8601String() 
                       ?? DateTime.now().toIso8601String(),
          'photoUrl': userData['photoUrl'] ?? firebaseUser.photoURL,
          'isTherapist': userData['isTherapist'] ?? false,
          'therapistInfo': userData['therapistInfo'],
        });
      } else {
        // Usuario nuevo - crear documento en Firestore
        final appUser = AppUser.fromFirebaseUser(
          firebaseUser,
          displayName: firebaseUser.displayName,
        );
        await _createUserDocument(appUser);
        return appUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error en el inicio de sesión con Google: ${e.toString()}');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Resetear password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Actualizar en Firebase Auth
    if (name != null) {
      await user.updateDisplayName(name);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Actualizar en Firestore
    await _firestore.collection('users').doc(user.uid).update({
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Crear documento de usuario en Firestore
  Future<void> _createUserDocument(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Manejar excepciones de Firebase Auth
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }
}