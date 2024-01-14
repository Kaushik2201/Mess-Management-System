import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/admin/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class ApproveRequests extends StatefulWidget {
  @override
  _ApproveRequestsState createState() => _ApproveRequestsState();
}

class _ApproveRequestsState extends State<ApproveRequests> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _messes = [];
  String _selectedMess = '';
  int _currentVacancy = 0;

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

      int maxCapacity = selectedMess['maxCapacity'] ?? 0;
      List<dynamic> allottedStudents = selectedMess['allottedStudents'] ?? [];
      _currentVacancy = maxCapacity - allottedStudents.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Requests'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessButtons(),
            SizedBox(height: 16.0),
            _buildCurrentVacancy(),
            SizedBox(height: 16.0),
            _buildRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessButtons() {
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

  Widget _buildCurrentVacancy() {
    return _selectedMess.isEmpty
        ? SizedBox.shrink()
        : Text(
            'Current Vacancy: $_currentVacancy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
  }

  Widget _buildRequestsList() {
    return _selectedMess.isEmpty
        ? SizedBox.shrink()
        : FutureBuilder<List<Map<String, dynamic>>>(
            future: _databaseService.getPendingRequests(_selectedMess),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading requests'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No pending requests'));
              } else {
                List<Map<String, dynamic>> requests = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestTile(requests[index]);
                    },
                  ),
                );
              }
            },
          );
  }

  Widget _buildRequestTile(Map<String, dynamic> request) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          'User: ${request['userName']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${request['date']}'),
            Text('Year: ${request['userYear']}'),
            Text('Roll Number: ${request['rollNum']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () {
                _handleRequestApproval(request, true);
              },
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _handleRequestApproval(request, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequestApproval(
      Map<String, dynamic> request, bool isApproved) async {
    try {
      String userId = request['userId'];
      String messId = request['messId'];
      String rewusy = request['requestId'];
      print('uid: $userId');
      print('MessName: $messId');
      print('Request ID $rewusy');

      await _databaseService.handleRequestApproval(
        userId: userId,
        messId: messId,
        requestId: request['requestId'],
        isApproved: isApproved,
      );

      if (isApproved) {
        var selectedMess = _messes.firstWhere(
          (mess) => mess['messName'] == messId,
          orElse: () => {},
        );

        int maxCapacity = selectedMess['maxCapacity'] ?? 0;
        List<dynamic> allottedStudents = selectedMess['allottedStudents'] ?? [];
        int currentVacancy = maxCapacity - allottedStudents.length;

        setState(() {
          _currentVacancy = currentVacancy;
        });
      }

      setState(() {});

      String snackbarMessage = isApproved
          ? 'Request approved for ${request['userName']}'
          : 'Request rejected for ${request['userName']}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error handling request approval: $e');
    }
  }
}
