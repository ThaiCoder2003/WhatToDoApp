import 'package:flutter/material.dart';
import 'package:what_to_do/controller/controller.dart';
import 'package:what_to_do/database/node_data.dart';

class HomePage extends StatefulWidget {
    @override
    _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    final NoteController _controller = NoteController();
    String _selectedCategory = 'All';

    @override
    void initState() {
        super.initState();
        _controller.fetchToDos();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('What To Do'),
            ),
            body: Row(
                children: [
                    _buildSideBar(),
                    Expanded(
                        child: _buildToDoList(),
                    ),
                ],
            ),
        );
    }

    Widget _buildSideBar() {
        return Container(
            width: 200,
            color: Colors.grey[200],
            child: Column(
                children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            decoration: InputDecoration(
                                hintText: 'Search...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                                _controller.searchToDos(value);
                            },
                        ),
                    ),
                    ListTile(
                        title: Text('All'),
                        onTap: () {
                            setState(() {
                                _selectedCategory = 'All';
                            });
                        },
                    ),
                    ListTile(
                        title: Text('Upcoming'),
                        onTap: () {
                            setState(() {
                                _selectedCategory = 'Upcoming';
                            });
                        },
                    ),
                    ListTile(
                        title: Text('Today'),
                        onTap: () {
                            setState(() {
                                _selectedCategory = 'Today';
                            });
                        },
                    ),
                    ListTile(
                        title: Text('Done'),
                        onTap: () {
                            setState(() {
                                _selectedCategory = 'Done';
                            });
                        },
                    ),
                    ListTile(
                        title: Text('Overdue'),
                        onTap: () {
                            setState(() {
                                _selectedCategory = 'Overdue';
                            });
                        },
                    ),
                    Spacer(),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Add ToDo'),
                            onPressed: () {
                                _showAddToDoDialog();
                            },
                        ),
                    ),
                ],
            ),
        );
    }

    void _showAddToDoDialog() {
        final _titleController = TextEditingController();
        final _descriptionController = TextEditingController();
        DateTime? _selectedDate;

        showDialog(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: Text('Add ToDo'),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                                controller: _titleController,
                                decoration: InputDecoration(labelText: 'Title'),
                            ),
                            TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(labelText: 'Description'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: () async {
                                    _selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                    );
                                },
                                child: Text('Select End Date'),
                            ),
                        ],
                    ),
                    actions: [
                        TextButton(
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                        ),
                        TextButton(
                            onPressed: () async {
                                if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _selectedDate != null) {
                                    final newNote = Note(
                                        title: _titleController.text,
                                        description: _descriptionController.text,
                                        endDate: _selectedDate!,
                                        category: 'Upcoming', // Default category
                                    );
                                    await _controller.createToDo(newNote);
                                    Navigator.of(context).pop();
                                    setState(() {});
                                }
                            },
                            child: Text('Add'),
                        ),
                    ],
                );
            },
        );
    }

    Widget _buildToDoList() {
        return FutureBuilder(
            future: _controller.fetchToDos(),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                    return ListView.builder(
                        itemCount: _controller.todos.length,
                        itemBuilder: (context, index) {
                            final note = _controller.todos[index];
                            if (_selectedCategory == 'All' || note.category == _selectedCategory) {
                                return ListTile(
                                    title: Text(note.title),
                                    subtitle: Text(note.description),
                                    trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                            await _controller.deleteToDo(note);
                                            setState(() {});
                                        },
                                    ),
                                    tileColor: _getCategoryColor(note.category),
                                    leading: Text(note.category),
                                );
                            } else {
                                return Container();
                            }
                        },
                    );
                }
            },
        );
    }

    Color _getCategoryColor(String category) {
        switch (category) {
            case 'Upcoming':
                return Colors.blue[100];
            case 'Today':
                return Colors.green[100];
            case 'Done':
                return Colors.grey[300];
            case 'Overdue':
                return Colors.red[100];
        }
    }
}