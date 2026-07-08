import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import 'notification_service.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get userDoc =>
      _firestore.collection('users').doc(uid);

  // Create Goal
  Future<void> addGoal(GoalModel goal) async {
    final doc = await userDoc.get();
    List<dynamic> goalsList = [];
    if (doc.exists && doc.data()!.containsKey('goals')) {
      goalsList = List.from(doc.data()!['goals']);
    }

    final newId = const Uuid().v4();
    final newGoal = goal.copyWith(id: newId);
    goalsList.add(newGoal.toMap());

    await userDoc.set({'goals': goalsList}, SetOptions(merge: true));
  }

  // Read Goals
  Stream<List<GoalModel>> getGoals() {
    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists ||
          snapshot.data() == null ||
          !snapshot.data()!.containsKey('goals')) {
        return [];
      }
      final list = snapshot.data()!['goals'] as List<dynamic>;
      return list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final id = map['id'] ?? '';
        return GoalModel.fromMap(map, id);
      }).toList();
    });
  }

  // Update Goal
  Future<void> updateGoal(GoalModel goal) async {
    final doc = await userDoc.get();
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('goals')) {
      final goalsList = List.from(doc.data()!['goals']);
      final index = goalsList.indexWhere((item) => item['id'] == goal.id);
      if (index != -1) {
        goalsList[index] = goal.toMap();
        await userDoc.update({'goals': goalsList});
      }
    }
  }

  // Add Money to Goal
  Future<void> addMoneyToGoal(String goalId, double amount) async {
    final doc = await userDoc.get();
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('goals')) {
      final goalsList = List.from(doc.data()!['goals']);
      final index = goalsList.indexWhere((item) => item['id'] == goalId);
      if (index != -1) {
        final map = Map<String, dynamic>.from(goalsList[index]);
        final currentAmount = (map['currentAmount'] ?? 0.0).toDouble();
        final targetAmount = (map['targetAmount'] as num).toDouble();

        double updatedAmount = currentAmount + amount;

        // Don't allow saving more than target
        if (updatedAmount > targetAmount) {
          updatedAmount = targetAmount;
        }

        map['currentAmount'] = updatedAmount;
        goalsList[index] = map;

        await userDoc.update({'goals': goalsList});

        // Show notification only once when goal becomes complete
        if (currentAmount < targetAmount && updatedAmount >= targetAmount) {
          await NotificationService.instance.showGoalCompleted(
            goalName: map['title'],
          );
        }
      }
    }
  }

  Future<void> withdrawMoneyFromGoal(String goalId, double amount) async {
    final doc = await userDoc.get();

    if (doc.exists && doc.data() != null && doc.data()!.containsKey('goals')) {
      final goalsList = List.from(doc.data()!['goals']);

      final index = goalsList.indexWhere((item) => item['id'] == goalId);

      if (index != -1) {
        final map = Map<String, dynamic>.from(goalsList[index]);

        final currentAmount = (map['currentAmount'] as num).toDouble();

        map['currentAmount'] = currentAmount - amount;

        goalsList[index] = map;

        await userDoc.update({'goals': goalsList});
      }
    }
  }

  // Delete Goal
  Future<void> deleteGoal(String goalId) async {
    final doc = await userDoc.get();
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('goals')) {
      final goalsList = List.from(doc.data()!['goals']);
      goalsList.removeWhere((item) => item['id'] == goalId);
      await userDoc.update({'goals': goalsList});
    }
  }
}
