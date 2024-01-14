import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/user/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class EditInfoScreen extends StatefulWidget {
  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Edit Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future:
              _databaseService.getUserData(_authService.getCurrentUserUid()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              Map<String, dynamic> userData =
                  snapshot.data as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile(
                        'Name', userData['name'], Icons.person, 'name'),
                    _buildInfoTile(
                        'Email Id', userData['email'], Icons.email, 'email'),
                    _buildInfoTile('Roll number', userData['rollNumber'],
                        Icons.format_list_numbered, 'rollNumber'),
                    _buildInfoTile('Academic Year', userData['year'],
                        Icons.date_range, 'year'),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String subtitle, IconData icon, String fieldKey) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: Icon(icon),
        title: Text(title, style: TextStyle(fontSize: 18.0)),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(subtitle, style: TextStyle(fontSize: 16.0)),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(context, title, subtitle, fieldKey);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue,
      String fieldKey) {
    TextEditingController _controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title', style: TextStyle(fontSize: 20.0)),
          content: SingleChildScrollView(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: title),
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
                String newValue = _controller.text.trim();
                bool confirm = await _showConfirmDialog(
                    context, title, currentValue, newValue);
                if (confirm) {
                  setState(() {
                    currentValue = newValue;
                  });

                  await _databaseService.updateUserInfo(
                      _authService.getCurrentUserUid(), fieldKey, newValue);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context, String title,
      String currentValue, String newValue) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Edit'),
              content: Text(
                  'Are you sure you want to update your $title from $currentValue to $newValue?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
