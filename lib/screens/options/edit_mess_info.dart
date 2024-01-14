import 'package:flutter/material.dart';
import 'package:mess_management_system/services/database_service.dart';

class EditMessInfoScreen extends StatefulWidget {
  final String adminUid;
  final String messName;

  EditMessInfoScreen({required this.adminUid, required this.messName});

  @override
  _EditMessInfoScreenState createState() => _EditMessInfoScreenState();
}

class _EditMessInfoScreenState extends State<EditMessInfoScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _messNameController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _breakfastPriceController =
      TextEditingController();
  final TextEditingController _lunchPriceController = TextEditingController();
  final TextEditingController _snacksPriceController = TextEditingController();
  final TextEditingController _dinnerPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExistingMessData();
  }

  Future<void> _fetchExistingMessData() async {
    try {
      Map<String, dynamic>? existingMessData =
          await _databaseService.getMessInfo(
        adminUid: widget.adminUid,
        messName: widget.messName,
      );
      if (existingMessData != null) {
        setState(() {
          _messNameController.text = widget.messName;
          _maxCapacityController.text =
              existingMessData['maxCapacity'].toString();
          _breakfastPriceController.text =
              existingMessData['breakfastPrice'].toString();
          _lunchPriceController.text =
              existingMessData['lunchPrice'].toString();
          _snacksPriceController.text =
              existingMessData['snacksPrice'].toString();
          _dinnerPriceController.text =
              existingMessData['dinnerPrice'].toString();
        });
      }
    } catch (e) {
      print('Error fetching existing mess data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Mess Info'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Mess Name:'),
              TextField(
                controller: _messNameController,
              ),
              SizedBox(height: 16.0),
              Text('Max Capacity:'),
              TextField(
                controller: _maxCapacityController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              Text('Breakfast Price:'),
              TextField(
                controller: _breakfastPriceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              Text('Lunch Price:'),
              TextField(
                controller: _lunchPriceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              Text('Snacks Price:'),
              TextField(
                controller: _snacksPriceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              Text('Dinner Price:'),
              TextField(
                controller: _dinnerPriceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_validateInputs()) {
                    String newMessName = _messNameController.text.trim();
                    int maxCapacity = int.parse(_maxCapacityController.text);
                    int breakfastPrice =
                        int.parse(_breakfastPriceController.text);
                    int lunchPrice = int.parse(_lunchPriceController.text);
                    int snacksPrice = int.parse(_snacksPriceController.text);
                    int dinnerPrice = int.parse(_dinnerPriceController.text);
                    await _databaseService.updateMessInfo(
                      adminUid: widget.adminUid,
                      oldMessName: widget.messName,
                      newMessName: newMessName,
                      maxCapacity: maxCapacity,
                      breakfastPrice: breakfastPrice,
                      lunchPrice: lunchPrice,
                      snacksPrice: snacksPrice,
                      dinnerPrice: dinnerPrice,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Update Mess Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (!_isInputValid(_maxCapacityController.text) ||
        !_isInputValid(_breakfastPriceController.text) ||
        !_isInputValid(_lunchPriceController.text) ||
        !_isInputValid(_snacksPriceController.text) ||
        !_isInputValid(_dinnerPriceController.text)) {
      _showAlertDialog(
        context,
        'Warning',
        'Invalid input. Please enter valid numbers.',
      );
      return false;
    }

    int newMaxCapacity = int.parse(_maxCapacityController.text);
    List<dynamic> allottedStudents = [];
    if (newMaxCapacity < allottedStudents.length) {
      _showAlertDialog(
        context,
        'Warning',
        'Cannot set max capacity less than the number of allotted students.',
      );
      return false;
    }
    return true;
  }

  bool _isInputValid(String value) {
    if (value.isEmpty) {
      return false;
    }

    try {
      int.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _showAlertDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
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
