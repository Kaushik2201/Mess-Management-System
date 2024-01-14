import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management_system/screens/admin/home.dart';
import 'package:mess_management_system/screens/authenticate/login.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';
import 'package:mess_management_system/shared/constants.dart';
import 'package:mess_management_system/shared/loading.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool isRegisterMode = false;
  bool isObscure = true;
  String email = "";
  String error = "";
  String password = "";
  String _emailError = '';
  String _passwordError = '';
  bool isLoading = false;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _resetEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return isLoading
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
                ],
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Admin Login",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          email = val;
                          error = '';
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
                            isObscure ? Icons.visibility : Icons.visibility_off,
                            color: Colors.teal,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                      ),
                      obscureText: isObscure,
                      onChanged: (val) {
                        setState(() {
                          password = val;
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
                              isObscure = true;
                              _emailError = _validateEmail(email);
                              _passwordError = _validatePassword(password);
                            });

                            if (_emailError.isEmpty && _passwordError.isEmpty) {
                              setState(() {
                                isLoading = true;
                              });

                              await adminLogin();

                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: Text("Log In"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => isObscure = !isObscure);
                            _showForgotPasswordPopup();
                          },
                          child: Text("Forgot Password?"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserLogin()),
                        );
                      },
                      child: Text("User Login"),
                    ),
                    SizedBox(height: 20),
                    if (error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> adminLogin() async {
    try {
      String? authResult = await _authService.adminLogin(email, password);

      if (authResult == null) {
        Map<String, dynamic>? userData = await _databaseService
            .getMessData(AuthService().getCurrentUserUid());
        if (userData == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text("This account is not registered as an admin."),
                actions: <Widget>[
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
          return;
        }
        bool isExist = userData['isExist'] ?? false;
        if (!isExist) {
          await _databaseService.addMess(
            userId: _authService.getCurrentUserUid(),
            messes: [
              {
                'messName': 'Mess1',
                'timeTable': {
                  'Monday': 'Breakfast',
                  'Tuesday': 'Lunch',
                },
                'breakfastPrice': 10,
                'lunchPrice': 20,
                'snacksPrice': 5,
                'dinnerPrice': 15,
                'incomingRequests': [],
                'allottedStudents': [],
                'deallocatedStudents': [],
                'rejectedStudents': [],
                'maxCapacity': 100,
              },
            ],
            isExist: true,
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      } else {
        setState(() {
          error = authResult;
        });
      }
    } catch (e) {
      print('Error during admin login: $e');
    }
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
}
