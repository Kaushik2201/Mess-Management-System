import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  String Uid = AuthService().getCurrentUserUid();

  String _generatedCaptcha = '';

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    _generatedCaptcha = (Random().nextInt(9000) + 1000).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Top-Up Mess Balance'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(
              controller: _amountController,
              labelText: 'Enter Amount for Top-Up [Min - 100]',
              icon: Icons.attach_money,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Captcha: $_generatedCaptcha',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _generateCaptcha();
                    });
                  },
                  child: Icon(Icons.refresh),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _captchaController,
              labelText: 'Enter Captcha',
              icon: Icons.security,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _handleTopUp(context);
              },
              child: Text('Top-Up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  void _handleTopUp(BuildContext context) async {
    String amountText = _amountController.text;
    String enteredCaptcha = _captchaController.text;

    int amount = int.tryParse(amountText) ?? 0;
    if (amount < 100) {
      _showWarningDialog(context, 'Please enter a minimum of 100 rupees.');
      return;
    }

    if (enteredCaptcha != _generatedCaptcha) {
      _showWarningDialog(context, 'Invalid captcha. Please try again.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Processing...'),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 2));

    await _databaseService.updateMessBalance(Uid, amount);

    Navigator.of(context).pop();

    _showSuccessDialog(context, 'Top-up successful!');
  }

  void _showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
