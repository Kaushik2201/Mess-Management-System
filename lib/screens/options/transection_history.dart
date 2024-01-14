import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/user/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class TransactionHistoryPage extends StatelessWidget {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _databaseService
            .getTransactionHistory(_authService.getCurrentUserUid()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> transactionHistory =
                snapshot.data as Map<String, dynamic>;

            if (transactionHistory.isEmpty) {
              return Center(child: Text('No transaction history available.'));
            }

            List<String> sortedDates = transactionHistory.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return SingleChildScrollView(
              child: Column(
                children: [
                  for (String date in sortedDates)
                    Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paid on $date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            for (String mealType in (transactionHistory[date]
                                    as Map<String, dynamic>)
                                .keys)
                              if (mealType != 'Current Bill Amount')
                                ListTile(
                                  title: Text(
                                      '$mealType: ${transactionHistory[date][mealType]}'),
                                ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
