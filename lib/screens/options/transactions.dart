import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/options/transection_history.dart';
import 'package:mess_management_system/screens/user/home.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  double currentBillAmount = 0.0;
  double currentBalance = 0.0;
  Set<String> selectedItems = Set();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Make Mess Payment'),
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
        future: _databaseService.getUserData(_authService.getCurrentUserUid()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> userData =
                snapshot.data as Map<String, dynamic>;
            currentBalance = userData['messBalance']?.toDouble() ?? 0.0;

            if (userData['currentMess'] == null) {
              return Center(child: Text('No mess allotted.'));
            } else {
              return FutureBuilder(
                future: _databaseService
                    .getMessDataForCurrentUser(userData['currentMess']),
                builder: (context, messSnapshot) {
                  if (messSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (messSnapshot.hasError) {
                    return Center(child: Text('Error: ${messSnapshot.error}'));
                  } else {
                    Map<String, dynamic> currentMessData =
                        messSnapshot.data as Map<String, dynamic>;

                    if (currentMessData.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Mess: ${userData['currentMess']}',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 25),
                            buildTile('Breakfast', userData, currentMessData),
                            buildTile('Lunch', userData, currentMessData),
                            buildTile('Snacks', userData, currentMessData),
                            buildTile('Dinner', userData, currentMessData),
                            SizedBox(height: 25),
                            Text(
                              'Current Bill Amount: ${currentBillAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Current Balance: ${currentBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  showConfirmationDialog(
                                      context, userData, currentMessData);
                                },
                                child: Text('Pay'),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Mess data not found for currentMess: ${userData['currentMess']}',
                        ),
                      );
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget buildTile(
    String mealType,
    Map<String, dynamic> userData,
    Map<String, dynamic> messData,
  ) {
    double mealPrice =
        messData['${mealType.toLowerCase()}Price']?.toDouble() ?? 0.0;

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$mealType Price: ${mealPrice.toStringAsFixed(2)}',
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add_shopping_cart),
            onPressed: selectedItems.contains(mealType)
                ? null
                : () {
                    addToCart(mealType, userData, messData);
                  },
          ),
          IconButton(
            icon: Icon(Icons.remove_shopping_cart),
            onPressed: selectedItems.contains(mealType)
                ? () {
                    removeFromCart(mealType, userData, messData);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void addToCart(
    String mealType,
    Map<String, dynamic> userData,
    Map<String, dynamic> messData,
  ) {
    setState(() {
      double price =
          messData['${mealType.toLowerCase()}Price']?.toDouble() ?? 0.0;
      userData['toPay'] = (userData['toPay'] ?? 0.0) + price;
      currentBillAmount += price;
      selectedItems.add(mealType);
    });
  }

  void removeFromCart(
    String mealType,
    Map<String, dynamic> userData,
    Map<String, dynamic> messData,
  ) {
    setState(() {
      double price =
          messData['${mealType.toLowerCase()}Price']?.toDouble() ?? 0.0;
      userData['toPay'] = (userData['toPay'] ?? 0.0) - price;
      currentBillAmount -= price;
      selectedItems.remove(mealType);
    });
  }

  Future<void> showConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> userData,
    Map<String, dynamic> messData,
  ) async {
    bool isTransactionInProgress = false;
    bool transactionSuccess = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (String mealType in [
                      'Breakfast',
                      'Lunch',
                      'Snacks',
                      'Dinner'
                    ])
                      if (selectedItems.contains(mealType))
                        Text(
                          '$mealType - ${messData['${mealType.toLowerCase()}Price'].toDouble().toStringAsFixed(2)}',
                        ),
                    SizedBox(height: 16),
                    Text(
                      'Current Bill Amount: ${currentBillAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Current Balance: ${currentBalance.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                SizedBox(width: 8),
                if (!isTransactionInProgress)
                  ElevatedButton(
                    onPressed: () async {
                      if (currentBillAmount <= 0.0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Warning'),
                            content: Text(
                                'Please add at least one item to your cart.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else if (currentBalance < currentBillAmount) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Warning'),
                            content: Text('Insufficient balance.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        setState(() {
                          isTransactionInProgress = true;
                        });

                        DateTime now = DateTime.now();
                        String formattedDate =
                            '${now.day}-${now.month}-${now.year}';

                        userData['mealEntries'][formattedDate] ??= {};

                        for (String mealType in [
                          'Breakfast',
                          'Lunch',
                          'Snacks',
                          'Dinner'
                        ]) {
                          if (selectedItems.contains(mealType)) {
                            userData['mealEntries'][formattedDate][mealType] =
                                messData['${mealType.toLowerCase()}Price'];
                          }
                        }

                        userData['messBalance'] -= currentBillAmount;

                        try {
                          await _databaseService.updateUserData(
                            _authService.getCurrentUserUid(),
                            userData,
                          );
                        } catch (e) {
                          print('Error updating user data: $e');
                        }

                        await Future.delayed(Duration(seconds: 3));

                        transactionSuccess = true;

                        setState(() {
                          currentBillAmount = 0.0;
                          selectedItems.clear();
                          isTransactionInProgress = false;
                        });

                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Confirm'),
                  ),
                if (isTransactionInProgress)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        );
      },
    ).then((value) {
      if (transactionSuccess) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Transaction Successful'),
            content: Text('Your transaction was successful!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TransactionHistoryPage()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
}
