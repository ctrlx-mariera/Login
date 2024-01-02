import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication.dart';
import 'dart:convert';
import 'package:http/http.dart';

const String apiUrl = 'https://expressway.cargen.com/api/v1/login';
const String networkErrorMessage =
    'Network error: Please check your internet connection.';
const String serverErrorMessage = 'Server error, please try again later.';
const String invalidResponseErrorMessage = 'Invalid email or password.';
const String passwordStrengthMessage =
    'Password must be at least 6 characters.';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> _signIn(BuildContext context) async {
    final auth = Provider.of<Authentication>(context, listen: false);

    if (auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You are already logged in."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final response = await performLogin();

        if (response.statusCode == 200) {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;

          if (responseData.containsKey('access_token')) {
            final String accessToken = responseData['access_token'] as String;
            // Display the access token in the IDE terminal
            print("Access Token: $accessToken");

            // Show a success Snackbar with a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sign-in successful."),
                duration: Duration(seconds: 5),
              ),
            );

            auth.login(accessToken);
          } else {
            handleInvalidResponse();
          }
        } else if (response.statusCode >= 500) {
          handleServerException();
        } else {
          handleInvalidResponse();
        }
      } catch (e) {
        handleNetworkException();
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Response> performLogin() async {
    return post(
      Uri.parse(apiUrl),
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );
  }

  void handleNetworkException() {
    showErrorMessage(networkErrorMessage);
  }

  void handleServerException() {
    showErrorMessage(serverErrorMessage);
  }

  void handleInvalidResponse() {
    showErrorMessage(invalidResponseErrorMessage);
  }

  void showErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage!),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              _inputField("Email", emailController, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Invalid email format';
                }
                return null;
              }),
              const SizedBox(height: 20),
              _inputField("Password", passwordController, isPassword: true,
                  validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return passwordStrengthMessage;
                }
                return null;
              }),
              const SizedBox(height: 50),
              isLoading
                  ? const CircularProgressIndicator()
                  : _loginButton(context),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {isPassword = false, String? Function(String?)? validator}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.black),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: border,
          focusedBorder: border,
        ),
        obscureText: isPassword,
        validator: validator,
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _signIn(context),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
      ),
      child: const Text(
        "Sign In",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
