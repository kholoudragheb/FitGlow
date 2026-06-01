class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      // Map "Client" back to "Customer" if needed, but we'll ensure 'Customer' is passed
      'role': role == 'Client' ? 'Customer' : role,
    };
  }
}
