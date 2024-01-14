import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/authenticate/login.dart';
import 'package:mess_management_system/screens/options/edit_info.dart';
import 'package:mess_management_system/screens/options/avl_mess.dart';
import 'package:mess_management_system/screens/options/mess_change_history.dart';
import 'package:mess_management_system/screens/options/top_up.dart';
import 'package:mess_management_system/screens/options/transactions.dart';
import 'package:mess_management_system/screens/options/transection_history.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> initialData =
          await _databaseService.getUserData(_authService.getCurrentUserUid());

      setState(() {
        userData = initialData;
      });
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${userData['rollNumber']}'),
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
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData['name'] ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditInfoScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.money, color: Colors.blue),
              title: Text('Top-Up Mess Balance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopUpPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.blue),
              title: Text('Available Mess'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvailableMessList()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.blue),
              title: Text('Mess Change History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.blue),
              title: Text('Mess Payment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.blue),
              title: Text('Transaction History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionHistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoTile('Name', userData['name'], Icons.person),
              _buildInfoTile('Email Id', userData['email'], Icons.email),
              _buildInfoTile('Roll number', userData['rollNumber'],
                  Icons.format_list_numbered),
              _buildInfoTile(
                  'Academic Year', userData['year'], Icons.date_range),
              _buildInfoTile(
                  'Current Mess', userData['currentMess'], Icons.restaurant),
              _buildInfoTile('Mess Balance', '${userData['messBalance']}',
                  Icons.account_balance_wallet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, dynamic value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: value != null
          ? Text(
              value.toString(),
              style: TextStyle(fontSize: 16),
            )
          : Text(
              'Loading...',
              style: TextStyle(fontSize: 16),
            ),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      Map<String, dynamic> updatedData =
          await _databaseService.getUserData(_authService.getCurrentUserUid());

      setState(() {
        userData = updatedData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
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
}
