import 'package:flutter/material.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';

class MenuPage extends StatelessWidget {
  final int messIndex;
  final Map<String, dynamic> timeTable;
  final Map<String, dynamic> messDetails;
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _AuthService = AuthService();

  MenuPage({
    required this.messIndex,
    required this.timeTable,
    required this.messDetails,
  });

  @override
  Widget build(BuildContext context) {
    String today = _getToday();
    String formattedDate = _getFormattedDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' $today, $formattedDate',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  '${messDetails['messName']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.teal,
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              buildMenuTable(),
              SizedBox(height: 24.0),
              Text(
                'Breakfast Price: ${messDetails['breakfastPrice']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Lunch Price: ${messDetails['lunchPrice']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Snacks Price: ${messDetails['snacksPrice']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Dinner Price: ${messDetails['dinnerPrice']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Allotted Students: ${messDetails['allottedStudents'].length}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Maximum Capacity: ${messDetails['maxCapacity']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> userData = await _databaseService
                        .getUserData(_AuthService.getCurrentUserUid());

                    String uMessName = userData['currentMess'];
                    String sMessName = messDetails['messName'];

                    int vac = messDetails['maxCapacity'] -
                        messDetails['allottedStudents'].length;

                    if (userData.isNotEmpty) {
                      bool hasPendingRequest = await DatabaseService()
                          .hasPendingRequest(AuthService().getCurrentUserUid());

                      if (hasPendingRequest) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Your request is already pending.'),
                          ),
                        );
                      } else if (uMessName == sMessName) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Your cannot make request to your current mess'),
                          ),
                        );
                      } else if (vac == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mess Full you cannot request'),
                          ),
                        );
                      } else {
                        String todayDate =
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

                        userData['changeMessHistory'][todayDate] =
                            messDetails['messName'];

                        await _databaseService.sendRequestToAdmin(
                          messDetails['messName'],
                          AuthService().getCurrentUserUid(),
                          userData['name'],
                          userData['email'],
                          userData['year'],
                          userData['rollNumber'],
                          todayDate,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Request sent successfully!'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('User data not found. Please try again.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'Change To This Mess',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _databaseService.deleteMessRequest(
                      _AuthService.getCurrentUserUid(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mess Request WithDrawn'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Withdraw Request',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          columns: <DataColumn>[
            DataColumn(
              label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: _getSortedTableRows(),
        ),
      ),
    );
  }

  List<DataRow> _getSortedTableRows() {
    List<String> orderedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    List<DataRow> sortedRows = [];
    for (String day in orderedDays) {
      List<DataCell> cells = [
        DataCell(Text(
          day,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        )),
        DataCell(
          Container(
            width: 200,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (timeTable.containsKey(day))
                    if (timeTable[day] is String)
                      Text(
                        '"${timeTable[day]}"',
                        softWrap: true,
                        style: TextStyle(fontSize: 15.0),
                      )
                    else if (timeTable[day] is Map<String, String>)
                      for (var entry in timeTable[day].entries)
                        Text('${entry.key}\n"${entry.value}"', softWrap: true),
                ],
              ),
            ),
          ),
        ),
      ];

      sortedRows.add(DataRow(cells: cells));
    }

    return sortedRows;
  }

  String _getToday() {
    DateTime now = DateTime.now();
    String day = '';

    switch (now.weekday) {
      case 1:
        day = 'Monday';
        break;
      case 2:
        day = 'Tuesday';
        break;
      case 3:
        day = 'Wednesday';
        break;
      case 4:
        day = 'Thursday';
        break;
      case 5:
        day = 'Friday';
        break;
      case 6:
        day = 'Saturday';
        break;
      case 7:
        day = 'Sunday';
        break;
    }

    return day;
  }

  String _getFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = '${now.day}/${now.month}/${now.year}';
    return formattedDate;
  }
}
