import 'package:flutter/material.dart';
import 'package:mess_management_system/screens/timeTable/menu.dart';
import 'package:mess_management_system/services/auth_service.dart';
import 'package:mess_management_system/services/database_service.dart';
import 'package:mess_management_system/shared/avl_mess_loading.dart';

class AvailableMessList extends StatefulWidget {
  @override
  _AvailableMessListState createState() => _AvailableMessListState();
}

class _AvailableMessListState extends State<AvailableMessList> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  bool isLoading = true;
  List<Map<String, dynamic>> messData = [];

  @override
  void initState() {
    super.initState();
    _loadMessData();
  }

  Future<void> _loadMessData() async {
    try {
      if (_authService.isUserAuthenticated()) {
        messData = await _databaseService.getAllMessData();
        setState(() {
          isLoading = false;
        });
      } else {
        print('User is not authenticated. Redirecting to login screen.');
      }
    } catch (e) {
      print('Error loading mess data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? aVLMESSLoading()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('Available Mess'),
              actions: [
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (messData.isEmpty)
                    Center(child: Text("No available mess"))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: messData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MessTile(
                            messData[index],
                            _authService.getCurrentUserUid(),
                            index,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
  }
}

class MessTile extends StatelessWidget {
  final Map<String, dynamic> mess;
  final String currentUserId;
  final int messIndex;

  MessTile(this.mess, this.currentUserId, this.messIndex);

  @override
  Widget build(BuildContext context) {
    List<dynamic> messList = mess['messList'] ?? [];

    return Column(
      children: messList.map<Widget>((messItem) {
        String messName = messItem['messName'] as String? ?? 'Unknown Mess';
        int maxCapacity = (messItem['maxCapacity'] ?? 0) as int;
        List<dynamic> allottedStudents =
            (messItem['allottedStudents'] ?? []) as List<dynamic>;
        int vacancy = maxCapacity - allottedStudents.length;

        return Card(
          elevation: 2.0,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              messName,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Vacancy: $vacancy'),
            trailing: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuPage(
                      messIndex: messIndex,
                      timeTable: messItem['timeTable'],
                      messDetails: messItem,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
