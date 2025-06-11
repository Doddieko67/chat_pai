// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo de Usuario
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
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

// Servicio de Autenticación (Simulado)
class AuthService {
  // Base de datos simulada en memoria
  static final Map<String, Map<String, dynamic>> _users = {};
  
  // Simular delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 1500));
  }
  
  // Registrar usuario
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    
    // Verificar si el email ya existe
    final existingUser = _users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('El correo electrónico ya está registrado');
    }
    
    // Crear nuevo usuario
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(
      id: userId,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    
    // Guardar usuario y contraseña
    _users[userId] = {
      ...user.toJson(),
      'password': password, // En producción esto debería estar hasheado
    };
    
    return user;
  }
  
  // Iniciar sesión
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    
    // Buscar usuario por email
    final userEntry = _users.entries.firstWhere(
      (entry) => entry.value['email'] == email,
      orElse: () => MapEntry('', {}),
    );
    
    if (userEntry.value.isEmpty) {
      throw Exception('Usuario no encontrado');
    }
    
    // Verificar contraseña
    if (userEntry.value['password'] != password) {
      throw Exception('Contraseña incorrecta');
    }
    
    return User.fromJson(userEntry.value);
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    await _simulateNetworkDelay();
    // En una app real, aquí se limpiarían tokens, etc.
  }
  
  // Obtener usuarios registrados (para debug)
  static Map<String, Map<String, dynamic>> getRegisteredUsers() {
    return Map.from(_users);
  }
}

// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Notifier para manejar el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  // Registrar usuario
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.register(
        name: name,
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

  // Iniciar sesión
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.login(
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
      await _authService.logout();
      state = AuthState(); // Reset completo del estado
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
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});