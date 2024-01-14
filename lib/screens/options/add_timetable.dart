import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/admin/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class AddTimetablePage extends StatefulWidget {
  final String selectedMessName;

  AddTimetablePage({required this.selectedMessName});

  @override
  _AddTimetablePageState createState() => _AddTimetablePageState();
}

class _AddTimetablePageState extends State<AddTimetablePage> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _selectedDay = 'Monday';
  String _breakfastMenu = '';
  String _lunchMenu = '';
  String _snacksMenu = '';
  String _dinnerMenu = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Update Mess Menu'),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHome()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  value: _selectedDay,
                  items: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ].map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedDay = value ?? 'Monday';
                      _clearTextFields();
                      _fetchMenuData();
                    });
                  },
                  decoration: InputDecoration(labelText: 'Day'),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _breakfastMenu = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Breakfast Menu'),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _lunchMenu = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Lunch Menu'),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _snacksMenu = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Snacks Menu'),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _dinnerMenu = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Dinner Menu'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (_breakfastMenu.isEmpty ||
                          _lunchMenu.isEmpty ||
                          _snacksMenu.isEmpty ||
                          _dinnerMenu.isEmpty) {
                        _showWarningDialog(
                            context, 'One or more fields are empty.');
                      } else {
                        await _updateTimetable();
                        _fetchMenuData();
                        _showUpdatePopup(context);
                        _clearTextFields();
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 16),
                Text(
                  'Current Mess Timetable:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchMenuData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error fetching timetable data: ${snapshot.error}');
                    } else {
                      return Text(snapshot.data?[_selectedDay] ?? '');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchMenuData() async {
    try {
      String adminUid = _auth.getCurrentUserUid();
      Map<String, dynamic>? existingMessData =
          await _databaseService.getMessData(adminUid);

      if (existingMessData != null &&
          existingMessData.containsKey('messList')) {
        List<Map<String, dynamic>> messList =
            List<Map<String, dynamic>>.from(existingMessData['messList']);

        var selectedMess = messList.firstWhere(
          (mess) => mess['messName'] == widget.selectedMessName,
          orElse: () => {},
        );

        if (selectedMess.isNotEmpty && selectedMess.containsKey('timeTable')) {
          return Map<String, dynamic>.from(selectedMess['timeTable']);
        }
      }
    } catch (e) {
      print('Error fetching timetable data: $e');
    }

    return {};
  }

  Future<void> _updateTimetable() async {
    try {
      String adminUid = _auth.getCurrentUserUid();
      Map<String, dynamic>? existingMessData =
          await _databaseService.getMessData(adminUid);

      if (existingMessData != null &&
          existingMessData.containsKey('messList')) {
        List<Map<String, dynamic>> updatedMesses =
            List<Map<String, dynamic>>.from(existingMessData['messList']);

        var selectedMess = updatedMesses.firstWhere(
          (mess) => mess['messName'] == widget.selectedMessName,
          orElse: () => {},
        );

        if (selectedMess.isNotEmpty) {
          selectedMess['timeTable'][_selectedDay] =
              'Breakfast: $_breakfastMenu\nLunch: $_lunchMenu\nSnacks: $_snacksMenu\nDinner: $_dinnerMenu';

          await _databaseService.addMess(
            userId: adminUid,
            messes: updatedMesses,
            isExist: true,
          );
        }
      }
    } catch (e) {
      print('Error updating timetable: $e');
    }
  }

  void _showUpdatePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Data Updated'),
          content: Text('The timetable data has been successfully updated.'),
          actions: [
            TextButton(
              onPressed: () {
                _clearTextFields();
                Navigator.of(context).pop(); // Close the dialog
                _navigateToAddTimetable();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddTimetable() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimetablePage(
          selectedMessName: widget.selectedMessName,
        ),
      ),
    );
  }

  void _clearTextFields() {
    setState(() {
      _breakfastMenu = '';
      _lunchMenu = '';
      _dinnerMenu = '';
      _snacksMenu = '';
    });
  }

  void _showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
          actions: [
            TextButton(
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
