class LoginData {
  final String username;
  final String password;

  LoginData(this.username, this.password);
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
