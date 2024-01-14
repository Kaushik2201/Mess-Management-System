import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management_system/screens/authenticate/admin/login.dart';
import 'package:mess_management_system/screens/authenticate/register.dart';
import 'package:mess_management_system/screens/user/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/shared/constants.dart';
import 'package:mess_management_system/shared/loading.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  bool _isObscure = true;
  String _email = '';
  String _password = '';
  String _emailError = '';
  String _passwordError = '';
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final TextEditingController _resetEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentDate,
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrationForm()),
                      );
                    },
                    icon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    label: Text(
                      "Register",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "User Login",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Salsa',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          hintText: "Email",
                          icon: Icon(Icons.email, color: Colors.teal),
                        ),
                        initialValue: '',
                        onChanged: (val) {
                          setState(() {
                            _email = val;
                            _emailError = '';
                          });
                        },
                      ),
                      if (_emailError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _emailError,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          hintText: "Password",
                          icon: Icon(Icons.lock, color: Colors.teal),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.teal,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        obscureText: _isObscure,
                        onChanged: (val) {
                          setState(() {
                            _password = val;
                            _passwordError = '';
                          });
                        },
                      ),
                      if (_passwordError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _passwordError,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isObscure = true;
                                _emailError = _validateEmail(_email);
                                _passwordError = _validatePassword(_password);
                              });

                              if (_emailError.isEmpty &&
                                  _passwordError.isEmpty) {
                                setState(() {
                                  _isLoading = true;
                                });

                                String? loginResult = await _authService
                                    .signInWithEmailAndPassword(
                                  _email,
                                  _password,
                                );

                                setState(() {
                                  _isLoading = false;
                                });

                                if (loginResult == null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                } else {
                                  _showErrorDialog(
                                      'Invalid Credentials', loginResult);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                            ),
                            child: Text(
                              "Log In",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _isObscure = !_isObscure);
                              _showForgotPasswordPopup();
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminLogin()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        child: Text(
                          "Admin Login",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  String _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Enter an Email';
    }
    return '';
  }

  String _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be 6 characters or more';
    }
    return '';
  }

  void _showForgotPasswordPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Forgot Password"),
          content: Column(
            children: [
              Text("Enter your registered email ID to reset your password:"),
              SizedBox(height: 10),
              TextFormField(
                controller: _resetEmailController,
                decoration: textInputDecoration.copyWith(
                  hintText: "Email",
                  icon: Icon(Icons.email, color: Colors.teal),
                ),
                validator: (val) => val!.isEmpty ? "Enter an Email" : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String resetEmail = _resetEmailController.text.trim();
                if (resetEmail.isNotEmpty) {
                  await _authService.resetPassword(resetEmail);
                  Navigator.of(context).pop();
                  setState(() => _resetEmailController.clear());
                  _showResetPasswordPopup();
                }
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  void _showResetPasswordPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Password Reset Email Sent"),
          content: Text(
              "An email to reset your password has been sent to your registered email address."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
