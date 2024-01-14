import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management_system/services/auth_service.dart';

class DatabaseService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference messCollection =
      FirebaseFirestore.instance.collection('mess');

  final CollectionReference messHistory =
      FirebaseFirestore.instance.collection('messRequests');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userId, String name, String email,
      String rollNumber, String programme, String year) async {
    return await usersCollection.doc(userId).set({
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'programme': programme,
      'year': year,
      'currentMess': 'Not allotted',
      'messBalance': 0,
      'mealEntries': {},
      'changeMessHistory': {},
    });
  }

  Future<void> addMess({
    required String userId,
    required List<Map<String, dynamic>> messes,
    required bool isExist,
  }) async {
    return await messCollection
        .doc(userId)
        .set({'messList': messes, 'isExist': isExist});
  }

  Future<void> updateMessBalance(String userId, int amount) async {
    try {
      DocumentSnapshot snapshot = await usersCollection.doc(userId).get();
      int currentBalance = snapshot.get('messBalance') ?? 0;

      await usersCollection.doc(userId).update({
        'messBalance': currentBalance + amount,
      });
    } catch (e) {
      print('Error: $e');
      throw 'Mess balance update failed. Please try again.';
    }
  }

  Future<void> updateUserData(
      String userId, Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(userId).update(userData);
    } catch (e) {
      print('Error updating user data: $e');
      throw 'Failed to update user data. Please try again.';
    }
  }

  Future<void> addMealEntry(
      String userId, String date, Map<String, int> entries) async {
    return await usersCollection.doc(userId).update({
      'mealEntries.$date': entries,
    });
  }

  Future<void> updateUserInfo(
      String userId, String fieldKey, String newValue) async {
    return await usersCollection.doc(userId).update({
      fieldKey: newValue,
    });
  }

  Future<Map<String, dynamic>?> getMessData(String messId) async {
    try {
      DocumentSnapshot snapshot = await messCollection.doc(messId).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error fetching mess data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot snapshot = await usersCollection.doc(userId).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAllMessData() async {
    try {
      QuerySnapshot querySnapshot = await messCollection.get();

      List<Map<String, dynamic>> messData = querySnapshot.docs
          .where((document) => document.exists)
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList();

      return messData;
    } catch (e) {
      print('Error fetching all mess data: $e');
      return [];
    }
  }

  Future<bool> hasPendingRequest(String userId) async {
    try {
      QuerySnapshot querySnapshot = await messHistory
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Pending')
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking pending request: $e');
      return false;
    }
  }

  Future<void> sendRequestToAdmin(String messId, String userId, String userName,
      String userEmail, String year, String rollnum, String date) async {
    try {
      await messHistory.doc(userId).set({
        'messId': messId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userYear': year,
        'rollNum': rollnum,
        'date': date,
        'status': 'Pending',
      });
    } catch (e) {
      print('Error sending request to admin: $e');
      throw 'Failed to send request. Please try again.';
    }
  }

  Future<List<Map<String, dynamic>>> getMessHistory(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('messRequests')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> messHistory = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        messHistory.add(data);
      }

      return messHistory;
    } catch (e) {
      print('Error getting mess history: $e');
      throw e;
    }
  }

  Future<void> deleteMessRequest(String userId) async {
    try {
      await messHistory.doc(userId).delete();
    } catch (e) {
      print('Error deleting mess request: $e');
    }
  }

  Stream<List<DocumentSnapshot>> listenToMessRequestChanges(String userId) {
    try {
      return usersCollection
          .doc(userId)
          .collection('messRequests')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where(
                  (doc) => doc['status'] != null && doc['status'] != 'Pending')
              .toList());
    } catch (e) {
      print('Error listening to mess request changes: $e');

      return Stream.value([]);
    }
  }

  Future<Map<String, dynamic>?> getMessInfo({
    required String adminUid,
    required String messName,
  }) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('mess').doc(adminUid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? messData =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (messData != null && messData.containsKey('messList')) {
          List<dynamic>? messList = messData['messList'];

          if (messList != null) {
            Map<String, dynamic>? selectedMess = messList.firstWhere(
              (mess) => mess['messName'] == messName,
              orElse: () => {},
            );

            return selectedMess;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error fetching mess info: $e');
      return null;
    }
  }

  Future<void> updateMessInfo({
    required String adminUid,
    required String oldMessName,
    required String newMessName,
    required int maxCapacity,
    required int breakfastPrice,
    required int lunchPrice,
    required int snacksPrice,
    required int dinnerPrice,
  }) async {
    try {
      Map<String, dynamic>? existingMessData = await getMessData(adminUid);

      if (existingMessData != null &&
          existingMessData.containsKey('messList')) {
        List<Map<String, dynamic>> updatedMesses =
            List<Map<String, dynamic>>.from(existingMessData['messList']);

        int messIndex = updatedMesses.indexWhere(
          (mess) => mess['messName'] == oldMessName,
        );

        if (messIndex != -1) {
          updatedMesses[messIndex]['messName'] = newMessName;
          updatedMesses[messIndex]['maxCapacity'] = maxCapacity;
          updatedMesses[messIndex]['breakfastPrice'] = breakfastPrice;
          updatedMesses[messIndex]['lunchPrice'] = lunchPrice;
          updatedMesses[messIndex]['snacksPrice'] = snacksPrice;
          updatedMesses[messIndex]['dinnerPrice'] = dinnerPrice;

          await messCollection.doc(adminUid).update({
            'messList': updatedMesses,
          });
        }
      }
    } catch (e) {
      print('Error updating mess info: $e');
    }
  }

  Future<Map<String, dynamic>?> getMessInfoWithoutAdminUidByIndex(
      int messIndex) async {
    try {
      QuerySnapshot querySnapshot = await messCollection.get();

      if (querySnapshot.docs.isNotEmpty &&
          messIndex >= 0 &&
          messIndex < querySnapshot.docs.length) {
        var document = querySnapshot.docs[messIndex];
        return document.exists ? document.data() as Map<String, dynamic> : null;
      }

      return null;
    } catch (e) {
      print('Error fetching mess info: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String messId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('messRequests')
          .where('messId', isEqualTo: messId)
          .where('status', isEqualTo: 'Pending')
          .get();

      List<Map<String, dynamic>> requests = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        requests.add(data);
      }

      return requests;
    } catch (e) {
      print('Error getting pending requests: $e');
      throw e;
    }
  }

  Future<void> updateRequestStatus({
    required String userId,
    required String messId,
    required String requestId,
    required bool isApproved,
  }) async {
    try {
      String status = isApproved ? 'Accepted' : 'Rejected';

      await _firestore
          .collection('messRequests')
          .doc(requestId)
          .update({'status': status});
    } catch (e) {
      print('Error updating request status: $e');
      throw e;
    }
  }

  Future<void> handleRequestApproval({
    required String userId,
    required String messId,
    required String requestId,
    required bool isApproved,
  }) async {
    try {
      String status = isApproved ? 'Accepted' : 'Rejected';

      await messHistory.doc(requestId).update({'status': status});

      if (status == 'Accepted') {
        String currentDate = DateTime.now().toLocal().toString().split(' ')[0];

        await usersCollection.doc(userId).update({
          'currentMess': messId,
          'changeMessHistory.$currentDate': messId,
        });

        String adminUid = AuthService().getCurrentUserUid();
        DocumentReference adminMessDocument = messCollection.doc(adminUid);

        try {
          DocumentSnapshot adminMessSnapshot = await adminMessDocument.get();

          if (adminMessSnapshot.exists) {
            List<dynamic> messesList = adminMessSnapshot['messList'];

            for (var mess in messesList) {
              List<dynamic> allottedStudents =
                  List.from(mess['allottedStudents']);
              allottedStudents.remove(userId);

              mess['allottedStudents'] = allottedStudents;
            }

            await adminMessDocument.update({
              'messList': messesList,
            });

            Map<String, dynamic>? selectedMess = messesList.firstWhere(
              (mess) => mess['messName'] == messId,
              orElse: () => null,
            );

            if (selectedMess != null) {
              List<dynamic> allottedStudents =
                  List.from(selectedMess['allottedStudents']);
              allottedStudents.add(userId);

              await adminMessDocument.update({
                'messList': FieldValue.arrayRemove([selectedMess]),
              });

              await adminMessDocument.update({
                'messList': FieldValue.arrayUnion([
                  {
                    ...selectedMess,
                    'allottedStudents': allottedStudents,
                  }
                ]),
              });
            } else {
              print('Selected mess not found: $messId');
            }
          } else {
            print('Admin Mess document not found: $adminUid');
          }
        } catch (e) {
          print('Error fetching mess document: $e');
        }
      } else {}
    } catch (e) {
      print('Error handling request approval: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getMessDataForCurrentUser(
      String currentMess) async {
    try {
      QuerySnapshot querySnapshot = await messCollection.get();

      List<Map<String, dynamic>> allMessData = querySnapshot.docs
          .where((document) => document.exists)
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList();

      Map<String, dynamic> currentMessData = {};

      for (var mess in allMessData) {
        var messList = mess['messList'] as List<dynamic>;
        var matchingMess = messList.firstWhere(
          (messItem) =>
              messItem['messName'] != null &&
              messItem['messName'].trim() == currentMess.trim(),
          orElse: () => null,
        );

        if (matchingMess != null) {
          currentMessData = matchingMess;
          break;
        }
      }

      return currentMessData;
    } catch (e) {
      print('Error fetching mess data: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData?['mealEntries'] != null) {
          return userData?['mealEntries'] ?? {};
        } else {
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      // Handle errors
      print('Error getting transaction history: $e');
      throw e;
    }
  }

  Future<void> updateMessData(
      String adminUid, Map<String, dynamic> data) async {
    try {
      await messCollection.doc(adminUid).update(data);
    } catch (e) {
      print('Error updating mess data: $e');
    }
  }
}
