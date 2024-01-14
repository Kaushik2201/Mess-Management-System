import 'package:flutter/material.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class MessHistoryPage extends StatefulWidget {
  @override
  _MessHistoryPageState createState() => _MessHistoryPageState();
}

class _MessHistoryPageState extends State<MessHistoryPage> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  List<Map<String, dynamic>> messHistory = [];
  Map<String, dynamic> changeMessHistory = {};

  @override
  void initState() {
    super.initState();
    _loadMessHistory();
    _loadChangeMessHistory();
  }

  Future<void> _loadMessHistory() async {
    try {
      String userId = _auth.getCurrentUserUid();
      List<Map<String, dynamic>> history =
          await _databaseService.getMessHistory(userId);

      setState(() {
        messHistory = history;
      });
    } catch (e) {
      print('Error loading mess history: $e');
    }
  }

  Future<void> _loadChangeMessHistory() async {
    try {
      String userId = _auth.getCurrentUserUid();
      Map<String, dynamic> changeHistory =
          await _databaseService.getUserData(userId);

      setState(() {
        changeMessHistory = changeHistory['changeMessHistory'];
      });
    } catch (e) {
      print('Error loading change mess history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Mess Change History'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Latest',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildMessHistoryList(messHistory),
            SizedBox(height: 16),
            Divider(
              thickness: 2,
              color: Colors.black,
            ),
            SizedBox(height: 8),
            Text(
              'Older',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildChangeMessHistoryList(changeMessHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildMessHistoryList(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return Center(
        child: Text('No mess history available.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: history.length,
      itemBuilder: (context, index) {
        return _buildMessHistoryCard(history[index]);
      },
    );
  }

  Widget _buildMessHistoryCard(Map<String, dynamic> historyItem) {
    String messName = historyItem['messId'];
    String date = historyItem['date'];
    String status = historyItem['status'];

    Color statusColor = _getStatusColor(status);

    if (status == 'Accepted') {
      _handleAcceptedStatus(historyItem);
    } else if (status == 'Rejected') {
      _handleRejectedStatus(historyItem);
    }

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          'Mess: $messName',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date'),
            Text(
              'Status: $status',
              style: TextStyle(color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAcceptedStatus(Map<String, dynamic> historyItem) async {
    Map<String, dynamic> userData =
        await _databaseService.getUserData(_auth.getCurrentUserUid());

    _databaseService.updateUserData(
      _auth.getCurrentUserUid(),
      userData,
    );

    if (historyItem.containsKey('messRequestId')) {
      _databaseService.deleteMessRequest(
        _auth.getCurrentUserUid(),
      );
    } else {
      print('Error: messRequestId key not found in historyItem.');
    }
  }

  void _handleRejectedStatus(Map<String, dynamic> historyItem) {
    if (historyItem.containsKey('messRequestId')) {
      _databaseService.deleteMessRequest(
        _auth.getCurrentUserUid(),
      );
    } else {
      print('Error: messRequestId key not found in historyItem.');
    }
  }

  Widget _buildChangeMessHistoryList(Map<String, dynamic> changeHistory) {
    if (changeHistory.isEmpty) {
      return Center(
        child: Text('No change mess history available.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: changeHistory.length,
      itemBuilder: (context, index) {
        String date = changeHistory.keys.toList()[index];
        String messName = changeHistory[date];

        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              'Mess changed to $messName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Date: $date'),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.shade700;
      case 'Rejected':
        return Colors.red.shade700;
      case 'Accepted':
        return Colors.green.shade700;
      default:
        return Colors.black;
    }
  }
}
