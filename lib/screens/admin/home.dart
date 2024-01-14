import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/authenticate/login.dart';
import 'package:mess_management_system/screens/options/add_timetable.dart';
import 'package:mess_management_system/screens/options/alloted_students.dart';
import 'package:mess_management_system/screens/options/approve.dart';
import 'package:mess_management_system/screens/options/edit_mess_info.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _messes = [];
  String _selectedMess = '';

  String _selectedMessName = '';
  int _selectedMaxCapacity = 0;
  int _selectedVacancy = 0;
  int _selectedBreakfastPrice = 0;
  int _selectedLunchPrice = 0;
  int _selectedSnacksPrice = 0;
  int _selectedDinnerPrice = 0;
  int _selectedAllottedStudentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMessData();
  }

  Future<void> _loadMessData() async {
    try {
      String adminUid = _authService.getCurrentUserUid();
      Map<String, dynamic>? messData =
          await _databaseService.getMessData(adminUid);

      if (messData != null && messData.containsKey('messList')) {
        setState(() {
          _messes = List<Map<String, dynamic>>.from(messData['messList']);
        });

        if (_messes.isNotEmpty) {
          _selectMess(_messes[0]['messName']);
        }
      }
    } catch (e) {
      print('Error loading mess data: $e');
    }
  }

  void _selectMess(String messName) {
    setState(() {
      _selectedMess = messName;

      var selectedMess = _messes.firstWhere(
        (mess) => mess['messName'] == messName,
        orElse: () => {},
      );

      _selectedMessName = selectedMess['messName'] ?? '';
      _selectedMaxCapacity = selectedMess['maxCapacity'] ?? 0;
      List<dynamic> allottedStudents = selectedMess['allottedStudents'] ?? [];
      _selectedVacancy = _selectedMaxCapacity - allottedStudents.length;
      _selectedBreakfastPrice = selectedMess['breakfastPrice'] ?? 0;
      _selectedLunchPrice = selectedMess['lunchPrice'] ?? 0;
      _selectedSnacksPrice = selectedMess['snacksPrice'] ?? 0;
      _selectedDinnerPrice = selectedMess['dinnerPrice'] ?? 0;
      _selectedAllottedStudentsCount = allottedStudents.length;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await _handleRefresh();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Update menu of this Mess'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddTimetable();
              },
            ),
            ListTile(
              leading: Icon(Icons.hourglass_bottom),
              title: Text('Pending Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApproveRequests()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add a Mess'),
              onTap: () {
                _showAddMessDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Update Mess Data'),
              onTap: () {
                String adminUid = _authService.getCurrentUserUid();
                String selectedMessName = _selectedMess;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMessInfoScreen(
                      adminUid: adminUid,
                      messName: selectedMessName,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Allotted Students'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AllottedStudentsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete this Mess'),
              onTap: () {
                _showDeleteConfirmationDialog(context, _selectedMessName);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMessList(),
              SizedBox(height: 16.0),
              _buildSelectedMessDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessList() {
    return _messes.isEmpty
        ? Center(child: Text("No messes added"))
        : Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _messes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _selectMess(_messes[index]['messName']);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor:
                          _selectedMess == _messes[index]['messName']
                              ? Colors.blue.shade500
                              : Colors.grey,
                      minimumSize: Size(120, 50),
                    ),
                    child: Text(
                      _messes[index]['messName'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildSelectedMessDetails() {
    return _selectedMess.isEmpty
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.location_city, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Mess Name: $_selectedMessName',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.people, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Max Capacity: $_selectedMaxCapacity',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.event_seat, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Vacancy: $_selectedVacancy',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.local_dining, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Breakfast Price: $_selectedBreakfastPrice',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.local_dining, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Lunch Price: $_selectedLunchPrice',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.local_dining, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Snacks Price: $_selectedSnacksPrice',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.local_dining, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Dinner Price: $_selectedDinnerPrice',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                SizedBox(height: 28.0),
                Row(
                  children: [
                    Icon(Icons.group, size: 30, color: Colors.blue),
                    SizedBox(width: 12.0),
                    Text(
                      'Allotted Students: $_selectedAllottedStudentsCount',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final AuthService _authService = AuthService();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out Confirmation'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _authService.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserLogin()),
                );
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String messName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Do you really want to delete the mess "$messName"?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _deleteMess();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMess() async {
    try {
      String adminUid = _authService.getCurrentUserUid();
      Map<String, dynamic>? existingMessData =
          await _databaseService.getMessData(adminUid);

      if (existingMessData != null &&
          existingMessData.containsKey('messList')) {
        List<Map<String, dynamic>> updatedMesses =
            List<Map<String, dynamic>>.from(existingMessData['messList'])
              ..removeWhere((mess) => mess['messName'] == _selectedMess);

        await _databaseService.addMess(
          userId: adminUid,
          messes: updatedMesses,
          isExist: true,
        );

        await _loadMessData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mess deleted successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          _selectedMess = '';
          _selectedMessName = '';
        });
      }
    } catch (e) {
      print('Error deleting mess: $e');
    }
  }

  Future<void> _showAddMessDialog(BuildContext context) async {
    TextEditingController _messNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a Mess'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _messNameController,
                  decoration: InputDecoration(labelText: 'Mess Name'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String messName = _messNameController.text.trim();

                if (messName.isEmpty) {
                  _showAlertDialog(
                      context, 'Warning', 'Mess Name cannot be empty.');
                  return;
                }

                String adminUid = _authService.getCurrentUserUid();
                Map<String, dynamic>? existingMessData =
                    await _databaseService.getMessData(adminUid);

                if (existingMessData != null &&
                    existingMessData.containsKey('messList')) {
                  List<Map<String, dynamic>> existingMesses =
                      List<Map<String, dynamic>>.from(
                          existingMessData['messList']);
                  bool messAlreadyExists = existingMesses
                      .any((mess) => mess['messName'] == messName);

                  if (messAlreadyExists) {
                    _showAlertDialog(context, 'Warning',
                        'Mess with the same name already exists.');
                    return;
                  }
                }

                List<Map<String, dynamic>> updatedMesses = [];
                if (existingMessData != null &&
                    existingMessData.containsKey('messList')) {
                  updatedMesses = List<Map<String, dynamic>>.from(
                      existingMessData['messList']);
                }

                updatedMesses.add({
                  'messName': messName,
                  'timeTable': {
                    'Monday': 'Breakfast',
                    'Tuesday': 'Lunch', /* ... */
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
                });

                await _databaseService.addMess(
                  userId: adminUid,
                  messes: updatedMesses,
                  isExist: true,
                );

                await _loadMessData();

                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    try {
      String adminUid = _authService.getCurrentUserUid();
      Map<String, dynamic>? updatedMessData =
          await _databaseService.getMessData(adminUid);

      if (updatedMessData != null && updatedMessData.containsKey('messList')) {
        setState(() {
          _messes =
              List<Map<String, dynamic>>.from(updatedMessData['messList']);
        });

        if (_selectedMess.isNotEmpty) {
          _selectMess(_selectedMess);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mess data refreshed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing mess data: $e');
    }
  }

  void _navigateToAddTimetable() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimetablePage(
          selectedMessName: _selectedMess,
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(
      BuildContext context, String title, String content) async {
    return showDialog(
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
