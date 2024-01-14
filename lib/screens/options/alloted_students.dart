import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/admin/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class AllottedStudentsPage extends StatefulWidget {
  @override
  _AllottedStudentsPageState createState() => _AllottedStudentsPageState();
}

class _AllottedStudentsPageState extends State<AllottedStudentsPage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _messes = [];
  String _selectedMess = '';

  List<String> _allottedStudents = [];

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

      _allottedStudents =
          List<String>.from(selectedMess['allottedStudents'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Allotted Students'),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessList(),
            SizedBox(height: 16.0),
            _buildAllottedStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessDropdown() {
    return _messes.isEmpty
        ? SizedBox.shrink()
        : DropdownButton<String>(
            value: _selectedMess,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _selectMess(newValue);
              }
            },
            items: _messes
                .map<DropdownMenuItem<String>>((Map<String, dynamic> mess) {
              return DropdownMenuItem<String>(
                value: mess['messName'],
                child: Text(mess['messName']),
              );
            }).toList(),
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

  Widget _buildAllottedStudentsList() {
    return _allottedStudents.isEmpty
        ? Center(child: Text("No students allotted to this mess"))
        : Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _allottedStudents.length,
                    itemBuilder: (context, index) {
                      String currentUserId = _allottedStudents[index];
                      return FutureBuilder(
                        future: _databaseService.getUserData(currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            Map<String, dynamic>? userData =
                                snapshot.data as Map<String, dynamic>?;

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(userData?['name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Year: ${userData?['year'] ?? ''}'),
                                    Text(
                                      'Roll Number: ${userData?['rollNumber'] ?? ''}',
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _showDeallocateConfirmationDialog(
                                        context, currentUserId);
                                  },
                                  child: Text('Deallocate'),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  void _showDeallocateConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deallocate Student'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Do you really want to deallocate the student?'),
              SizedBox(height: 16),
              FutureBuilder(
                future: _databaseService.getUserData(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    Map<String, dynamic>? userData =
                        snapshot.data as Map<String, dynamic>?;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${userData?['name'] ?? ''}'),
                        Text('Year: ${userData?['year'] ?? ''}'),
                        Text('Roll Number: ${userData?['rollNumber'] ?? ''}'),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Deny'),
            ),
            TextButton(
              onPressed: () {
                _handleDeallocate(userId);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeallocate(String userId) {
    _databaseService.updateUserData(userId, {'currentMess': 'Not allotted'});

    var selectedMess = _messes.firstWhere(
      (mess) => mess['messName'] == _selectedMess,
      orElse: () => {},
    );

    List<String> updatedAllottedStudents =
        List<String>.from(selectedMess['allottedStudents'] ?? []);
    updatedAllottedStudents.remove(userId);

    List<String> updatedDeallocatedStudents =
        List<String>.from(selectedMess['deallocatedStudents'] ?? []);
    updatedDeallocatedStudents.add(userId);

    _databaseService.updateMessData(_authService.getCurrentUserUid(), {
      'messList': _messes.map((mess) {
        if (mess['messName'] == _selectedMess) {
          return {
            ...mess,
            'allottedStudents': updatedAllottedStudents,
            'deallocatedStudents': updatedDeallocatedStudents,
          };
        } else {
          return mess;
        }
      }).toList(),
    });

    setState(() {
      _allottedStudents.remove(userId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student deallocated'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
