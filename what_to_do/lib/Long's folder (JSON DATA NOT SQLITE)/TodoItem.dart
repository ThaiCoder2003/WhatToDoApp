// TodoItem.dart
import 'dart:convert';

/// A class representing a single TODO item.
class TodoItem {
  String id;
  String name;
  String description;
  bool status; // true: completed, false: pending
  DateTime createdDate;
  DateTime dueDate;

  TodoItem({
    required this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.dueDate,
    this.status = false,
  });

  // Marks the item as complete.
  void markAsComplete() {
    status = true;
  }

  // Resets the item to pending.
  void undoMark() {
    status = false;
  }

  // Convert a TodoItem into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }

  // Create a TodoItem from a JSON map.
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate']),
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
    );
  }
}
