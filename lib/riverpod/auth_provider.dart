// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pai_app/services/firebase_auth_service.dart';

// Exportar AppUser como User para compatibilidad
typedef User = AppUser;

// Provider para saber si Firebase está inicializado
final firebaseInitializedProvider = Provider<bool>((ref) => false);

// Modelo de Usuario Mock para desarrollo
class MockUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;
  final bool isTherapist;
  final Map<String, dynamic>? therapistInfo;

  MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
    this.isTherapist = false,
    this.therapistInfo,
  });

  // Convertir a AppUser para compatibilidad
  AppUser toAppUser() {
    return AppUser(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt,
      photoUrl: photoUrl,
      isTherapist: isTherapist,
      therapistInfo: therapistInfo,
    );
  }
}

// Servicio de Autenticación Mock para desarrollo
class MockAuthService {
  static final Map<String, Map<String, dynamic>> _users = {};
  
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800));
  }
  
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    bool isTherapist = false,
  }) async {
    await _simulateNetworkDelay();
    
    final existingUser = _users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('El correo electrónico ya está registrado');
    }
    
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = MockUser(
      id: userId,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      isTherapist: isTherapist,
    );
    
    _users[userId] = {
      'id': userId,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
      'isTherapist': isTherapist,
    };
    
    return user.toAppUser();
  }
  
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    
    final userEntry = _users.entries.firstWhere(
      (entry) => entry.value['email'] == email,
      orElse: () => MapEntry('', {}),
    );
    
    if (userEntry.value.isEmpty) {
      throw Exception('Usuario no encontrado');
    }
    
    if (userEntry.value['password'] != password) {
      throw Exception('Contraseña incorrecta');
    }
    
    return MockUser(
      id: userEntry.value['id'],
      name: userEntry.value['name'],
      email: userEntry.value['email'],
      createdAt: DateTime.parse(userEntry.value['createdAt']),
      isTherapist: userEntry.value['isTherapist'] ?? false,
    ).toAppUser();
  }
  
  Future<void> signOut() async {
    await _simulateNetworkDelay();
  }
  
  Future<void> resetPassword(String email) async {
    await _simulateNetworkDelay();
    // Simular éxito siempre en modo mock
  }

  Future<AppUser> signInWithGoogle() async {
    await _simulateNetworkDelay();
    
    // Simular usuario de Google
    final userId = 'google_${DateTime.now().millisecondsSinceEpoch}';
    final user = MockUser(
      id: userId,
      name: 'Usuario de Google',
      email: 'google.user@gmail.com',
      createdAt: DateTime.now(),
      photoUrl: 'https://via.placeholder.com/150',
      isTherapist: false,
    );
    
    _users[userId] = {
      'id': userId,
      'name': 'Usuario de Google',
      'email': 'google.user@gmail.com',
      'password': 'google_auth',
      'createdAt': DateTime.now().toIso8601String(),
      'photoUrl': 'https://via.placeholder.com/150',
      'isTherapist': false,
    };
    
    return user.toAppUser();
  }
  
  static Map<String, Map<String, dynamic>> getRegisteredUsers() {
    return Map.from(_users);
  }
}

// Estado de Autenticación
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Provider del servicio de autenticación Firebase
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Provider del servicio de autenticación Mock
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});

// Provider que decide qué servicio usar
final authServiceProvider = Provider<dynamic>((ref) {
  final isFirebaseInitialized = ref.watch(firebaseInitializedProvider);
  if (isFirebaseInitialized) {
    return ref.read(firebaseAuthServiceProvider);
  } else {
    return ref.read(mockAuthServiceProvider);
  }
});

// Notifier universal para manejar autenticación
class UniversalAuthNotifier extends StateNotifier<AuthState> {
  final dynamic _authService;
  final bool _isFirebase;

  UniversalAuthNotifier(this._authService, this._isFirebase) : super(AuthState()) {
    if (_isFirebase && _authService is FirebaseAuthService) {
      // Escuchar cambios en el estado de autenticación de Firebase
      _authService.userStream.listen((user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: user != null,
          isLoading: false,
        );
      });
    }
  }

  // Registrar usuario
  Future<void> register({
    required String name,
    required String email,
    required String password,
    bool isTherapist = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      late AppUser user;
      if (_isFirebase) {
        user = await _authService.registerWithEmailAndPassword(
          name: name,
          email: email,
          password: password,
          isTherapist: isTherapist,
        );
      } else {
        user = await _authService.register(
          name: name,
          email: email,
          password: password,
          isTherapist: isTherapist,
        );
      }
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Iniciar sesión
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.signOut();
      state = AuthState(); // Reset completo del estado
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Resetear contraseña
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.signInWithGoogle();
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider principal de autenticación
final authProvider = StateNotifierProvider<UniversalAuthNotifier, AuthState>((ref) {
  final isFirebaseInitialized = ref.watch(firebaseInitializedProvider);
  final authService = ref.read(authServiceProvider);
  return UniversalAuthNotifier(authService, isFirebaseInitialized);
});