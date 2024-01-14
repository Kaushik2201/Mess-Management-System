import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/authenticate/login.dart';
import 'package:mess_management_system/screens/user/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _rollNumber = '';
  String _selectedProgram = 'BTech';
  String _selectedYear = '1';
  bool _isObscure = true;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Register",
              style: TextStyle(fontSize: 20),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserLogin()),
                  );
                });
              },
              icon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              label: Text(
                "Log In",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildEmailField(),
              SizedBox(height: 10),
              _buildPasswordField(),
              SizedBox(height: 10),
              _buildNameField(),
              SizedBox(height: 10),
              _buildRollNumberField(),
              SizedBox(height: 10),
              _buildProgramDropdown(),
              SizedBox(height: 10),
              _buildYearField(),
              SizedBox(height: 20),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        icon: Icon(Icons.email, color: Colors.teal),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val!.isEmpty) {
          return "Enter an Email";
        } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(val)) {
          return "Invalid Email";
        } else if (!val.endsWith('.com') &&
            !val.endsWith('.co.in') &&
            !val.endsWith('.edu.in')) {
          return "Invalid Email";
        } else if ((val.contains('google') ||
                val.contains('hotmail') ||
                val.contains('rediffmail') ||
                val.contains('outlook')) &&
            !val.endsWith('.com')) {
          return "Invalid Email";
        } else if (val.contains('yahoo') && !val.endsWith('.co.in')) {
          return "Invalid Email";
        }

        return null;
      },
      onSaved: (value) => _email = value!,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        icon: Icon(Icons.lock, color: Colors.teal),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
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
      validator: (val) =>
          val!.length < 6 ? "Strong Password 6 Characters+" : null,
      onChanged: (val) {
        setState(() => _password = val);
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Name',
        icon: Icon(Icons.person, color: Colors.teal),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
      onSaved: (value) => _name = value!,
    );
  }

  Widget _buildRollNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Roll Number',
        icon: Icon(Icons.format_list_numbered, color: Colors.teal),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your roll number';
        }
        return null;
      },
      onSaved: (value) => _rollNumber = value!,
    );
  }

  Widget _buildProgramDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedProgram,
      decoration: InputDecoration(
        labelText: 'Program',
        icon: Icon(Icons.school, color: Colors.teal),
      ),
      items: ['BTech', 'MTech', 'PHD']
          .map((program) => DropdownMenuItem(
                value: program,
                child: Text(program),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedProgram = value!;
        });
      },
    );
  }

  Widget _buildYearField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Year',
        icon: Icon(Icons.date_range, color: Colors.teal),
      ),
      initialValue: _selectedYear,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your year';
        }
        return null;
      },
      onSaved: (value) => _selectedYear = value!,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _submitForm();
          setState(() {
            _isObscure = true;
          });
        },
        child: Text('Register'),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate email
      String? emailCheckResult = await _authService.checkEmail(_email);
      if (emailCheckResult != null) {
        // Show error message for invalid email
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Email Validation Error'),
              content: Text(emailCheckResult),
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
        return; // Stop further execution if email is not valid
      }

      // Display confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Email: $_email'),
                Text('Name: $_name'),
                Text('Roll Number: $_rollNumber'),
                Text('Program: $_selectedProgram'),
                Text('Year: $_selectedYear'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // Perform registration logic here
                  // You can access the form values using _email, _password, etc.
                  // Add user to Firestore
                  await _authService.registerWithEmailAndPassword(
                      _email, _password);

                  await _databaseService.addUser(
                    _authService.getCurrentUserUid(),
                    _name,
                    _email,
                    _rollNumber,
                    _selectedProgram,
                    _selectedYear,
                  );

                  // Redirect to the home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }
}
