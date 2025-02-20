// Main.dart
import 'dart:io';
import "TodoList.dart";
import "TodoItem.dart";

// Main menu options.
const List<String> MAIN_OPTIONS_STRING = [
  "1. Add a new item",
  "2. Mark an item as completed",
  "3. Unmark an item",
  "4. Search",
  "6. Exit",
];

// Search menu options.
const List<String> SEARCH_OPTIONS_STRING = [
  "1. Search by Name",
  "2. Search by Category (All/Today/Upcoming)",
  "3. Search by Due Date",
  "4. Search by Created Date",
];

void main() {
  TodoList todoList = TodoList();
  // Load existing items on startup.
  todoList.loadFromFile();

  while (true) {
    printMainMenu();
    String? choice = stdin.readLineSync();
    clearScreen();
    switch (choice) {
      case "1":
        addNewItem(todoList);
        break;
      case "2":
        markItemAsCompleted(todoList);
        break;
      case "3":
        unmarkItem(todoList);
        break;
      case "4":
        searchItems(todoList);
        break;
      case "5":
        print("Exiting application. Goodbye!");
        exit(0);
      default:
        print("Invalid option. Please try again.");
    }
  }
}

void printMainMenu() {
  print("\nWelcome to TODO App");
  print("Please select an option:");
  for (var option in MAIN_OPTIONS_STRING) {
    print(option);
  }
}

void addNewItem(TodoList todoList) {
  clearScreen();
  print("Enter the name of the TODO item:");
  String? name = stdin.readLineSync();
  if (name == null || name.isEmpty) {
    print("Name cannot be empty.");
    return;
  }

  print("Enter description:");
  String? description = stdin.readLineSync();
  description = description ?? "";

  print("Enter due date and time (format: yyyy-MM-dd HH:mm):");
  String? dueInput = stdin.readLineSync();
  if (dueInput == null || dueInput.isEmpty) {
    print("Invalid input. Using current time as due date.");
    dueInput = DateTime.now().toString();
  }
  String formattedInput = dueInput.replaceAll(" ", "T");
  DateTime dueDate = DateTime.tryParse(formattedInput) ?? DateTime.now();

  DateTime createdDate = DateTime.now();
  String id = DateTime.now().millisecondsSinceEpoch.toString();

  TodoItem newItem = TodoItem(
    id: id,
    name: name,
    description: description,
    createdDate: createdDate,
    dueDate: dueDate,
  );

  todoList.add(newItem);
  print("TODO item added successfully with ID: $id");
  print("Press any key to continue...");
  stdin.readLineSync();
  clearScreen();
}

/// Marks an item as completed and optionally removes it from the list.
void markItemAsCompleted(TodoList todoList) {
  clearScreen();
  printItems(todoList.getAllUncompletedItems());
  print("Enter the ID of the item to mark as completed:");
  String? id = stdin.readLineSync();
  if (id == null || id.isEmpty) {
    print("Invalid ID.");
    return;
  }
  TodoItem? item;
  try {
    item = todoList.items.firstWhere((element) => element.id == id);
  } catch (e) {
    item = null;
  }
  if (item != null) {
    item.markAsComplete();
    todoList.saveToFile(); // Save the change
    print("Item marked as complete.");
    print("Do you want to remove this item from the list? (y/n)");
    String? removeChoice = stdin.readLineSync();
    if (removeChoice != null && removeChoice.toLowerCase() == 'y') {
      todoList.removeOneItem(id);
      print("Item removed from the list.");
    }
  } else {
    print("Item not found.");
  }
  print("Press any key to continue...");
  stdin.readLineSync();
  clearScreen();
}

/// Unmarks an item (sets it back to pending).
void unmarkItem(TodoList todoList) {
  clearScreen();
  printItems(todoList.getAllCompletedItems());
  print("Enter the ID of the item to unmark (set as not completed):");
  String? id = stdin.readLineSync();
  if (id == null || id.isEmpty) {
    print("Invalid ID.");
    return;
  }
  TodoItem? item;
  try {
    item = todoList.items.firstWhere((element) => element.id == id);
  } catch (e) {
    item = null;
  }
  if (item != null) {
    item.undoMark();
    todoList.saveToFile(); // Save the change
    print("Item unmarked (set as not completed).");
  } else {
    print("Item not found.");
  }
  print("Press any key to continue...");
  stdin.readLineSync();
  clearScreen();
}

void searchItems(TodoList todoList) {
  clearScreen();
  print("\nSearch Options:");
  for (var option in SEARCH_OPTIONS_STRING) {
    print(option);
  }
  String? searchChoice = stdin.readLineSync();
  switch (searchChoice) {
    case "1":
      print("Enter the name to search for:");
      String? name = stdin.readLineSync();
      if (name == null || name.isEmpty) {
        print("Invalid input.");
        return;
      }
      var results =
          todoList.items
              .where(
                (item) => item.name.toLowerCase().contains(name.toLowerCase()),
              )
              .toList();
      printItems(results);
      print("Press any key to continue...");
      stdin.readLineSync();
      clearScreen();
      break;
    case "2":
      print("Select category to search:");
      print("1. All");
      print("2. Today");
      print("3. Upcoming");
      String? catChoice = stdin.readLineSync();
      List<TodoItem> results;
      if (catChoice == "1") {
        results = todoList.getAllItems();
      } else if (catChoice == "2") {
        results = todoList.getTodayItems();
      } else if (catChoice == "3") {
        results = todoList.getUpcomingItems();
      } else {
        print("Invalid category.");
        return;
      }
      printItems(results);
      print("Press any key to continue...");
      stdin.readLineSync();
      clearScreen();
      break;
    case "3":
      print("Enter due date (format: yyyy-MM-dd):");
      String? dateStr = stdin.readLineSync();
      if (dateStr == null || dateStr.isEmpty) {
        print("Invalid input.");
        return;
      }
      DateTime? dueDate = DateTime.tryParse(dateStr);
      if (dueDate == null) {
        print("Invalid date format.");
        return;
      }
      var resultsDue = todoList.getItemsByDueDate(dueDate);
      printItems(resultsDue);
      print("Press any key to continue...");
      stdin.readLineSync();
      clearScreen();
      break;
    case "4":
      print("Enter created date (format: yyyy-MM-dd):");
      String? dateStr = stdin.readLineSync();
      if (dateStr == null || dateStr.isEmpty) {
        print("Invalid input.");
        return;
      }
      DateTime? createdDate = DateTime.tryParse(dateStr);
      if (createdDate == null) {
        print("Invalid date format.");
        return;
      }
      var resultsCreated = todoList.getItemsByCreatedDate(createdDate);
      printItems(resultsCreated);
      print("Press any key to continue...");
      stdin.readLineSync();
      clearScreen();
      break;
    default:
      print("Invalid search option.");

      print("Press any key to continue...");
      stdin.readLineSync();
      clearScreen();
  }
}

void clearScreen() {
  if (Platform.isWindows) {
    // Windows command
    Process.runSync("cls", [], runInShell: true);
  } else {
    // Unix-based OS (Linux, macOS)
    stdout.write("\x1B[2J\x1B[0;0H");
  }
}

/// Helper function to print a list of TODO items.
void printItems(List<TodoItem> items) {
  if (items.isEmpty) {
    print("No items found.");
  } else {
    print("\n--- TODO Items ---");
    for (var item in items) {
      print("ID: ${item.id}");
      print("Name: ${item.name}");
      print("Description: ${item.description}");
      print("Status: ${item.status ? 'Completed' : 'Pending'}");
      print("Created: ${item.createdDate}");
      print("Due: ${item.dueDate}");
      print("--------------------------");
    }
  }
}
