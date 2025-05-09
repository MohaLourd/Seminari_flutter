import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';

class AuthService {
  // Singleton
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  bool isLoggedIn = false; // Estado de autenticación
  User? _currentUser; // Datos del usuario autenticado

  User? get currentUser =>
      _currentUser; // Getter para acceder al usuario autenticado

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = json.encode({'email': email, 'password': password});

    try {
      print("Enviant solicitud POST a: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("Resposta rebuda amb codi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = User.fromJson(
          responseData,
        ); // Crea una instancia de User
        isLoggedIn = true; // Cambia el estado de autenticación a autenticado
        return _currentUser;
      } else {
        print("Error al iniciar sessió: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error al fer la solicitud: $e");
      return null;
    }
  }

  // Actualizar usuario
  Future<bool> updateUser(User updatedUser) async {
    final url = Uri.parse('$_baseUrl/${_currentUser?.id}');
    final body = json.encode(updatedUser.toJson());

    try {
      print("Enviant solicitud PUT a: $url");
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("Resposta rebuda amb codi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Verifica si la operación fue exitosa
        if (responseData['acknowledged'] == true &&
            responseData['modifiedCount'] > 0) {
          _currentUser =
              updatedUser; // Actualiza manualmente currentUser con updatedUser
          print("Usuario actualizado localmente: $responseData");
          return true;
        } else {
          print("Error: No se modificó el usuario.");
          return false;
        }
      } else {
        print("Error al actualizar el usuario: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error al fer la solicitud: $e");
      return false;
    }
  }

  // Logout
  void logout() {
    isLoggedIn = false; // Cambia el estado de autenticación a no autenticado
    _currentUser = null; // Limpia los datos del usuario autenticado
    print("Sessió tancada");
  }
}
