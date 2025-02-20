// TodoList.dart
import "TodoItem.dart";
import 'dart:io';
import 'dart:convert';

class TodoList {
  List<TodoItem> items = [];
  // Define the file path for storing the data.
  final String filePath = 'todo_data.json';

  void add(TodoItem item) {
    items.add(item);
    saveToFile();
  }

  bool removeOneItem(String id) {
    TodoItem? itemToRemove;
    try {
      itemToRemove = items.firstWhere((item) => item.id == id);
    } catch (e) {
      itemToRemove = null;
    }

    if (itemToRemove != null) {
      items.remove(itemToRemove);
      saveToFile();
      return true;
    }
    return false;
  }

  List<TodoItem> getAllCompletedItems() {
    return items.where((item) => item.status == true).toList();
  }

  List<TodoItem> getAllUncompletedItems() {
    return items.where((item) => item.status == false).toList();
  }

  List<TodoItem> getItemsByCreatedDate(DateTime createdDate) {
    return items.where((item) =>
      item.createdDate.year == createdDate.year &&
      item.createdDate.month == createdDate.month &&
      item.createdDate.day == createdDate.day
    ).toList();
  }

  List<TodoItem> getItemsByDueDate(DateTime dueDate) {
    return items.where((item) =>
      item.dueDate.year == dueDate.year &&
      item.dueDate.month == dueDate.month &&
      item.dueDate.day == dueDate.day
    ).toList();
  }

  List<TodoItem> getAllItems() {
    return items;
  }

  // Returns items due today.
  List<TodoItem> getTodayItems() {
    DateTime now = DateTime.now();
    return items.where((item) =>
      item.dueDate.year == now.year &&
      item.dueDate.month == now.month &&
      item.dueDate.day == now.day
    ).toList();
  }

  // Returns items due after today.
  List<TodoItem> getUpcomingItems() {
    DateTime now = DateTime.now();
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return items.where((item) => item.dueDate.isAfter(todayEnd)).toList();
  }

  // Save the current list of items to a JSON file.
  void saveToFile() {
    File file = File(filePath);
    List<Map<String, dynamic>> jsonList = items.map((item) => item.toJson()).toList();
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  // Load the list of items from a JSON file.
  void loadFromFile() {
    File file = File(filePath);
    if (file.existsSync()) {
      try {
        String contents = file.readAsStringSync();
        List<dynamic> jsonList = jsonDecode(contents);
        items = jsonList.map((json) => TodoItem.fromJson(json)).toList();
      } catch (e) {
        print("Error loading data: $e");
      }
    }
  }
}
