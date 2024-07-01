class RegisterData {
  final String email;
  final String name;
  final String username;
  final String password;

  RegisterData({
    required this.email,
    required this.name,
    required this.username,
    required this.password,
  });
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'password': password,
    };
  }
}
