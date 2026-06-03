import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  List<String> tasks = [];
  List<bool> completed = [];
  TextEditingController taskController = TextEditingController();

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      tasks = prefs.getStringList('tasks') ?? [];
      List<String> savedCompleted = prefs.getStringList('completed') ?? [];
      completed = savedCompleted.map((e) => e == 'true').toList();
      while (completed.length < tasks.length) {
        completed.add(false);
      }
    });
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', tasks);
    prefs.setStringList('completed', completed.map((e) => e.toString()).toList());
  }

  void addTask() {
    if (taskController.text.isEmpty) {
      return;
    }
    setState(() {
      tasks.add(taskController.text);
      completed.add(false);
      taskController.clear();
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      completed.removeAt(index);
    });
    saveTasks();
  }

  void toggleComplete(int index) {
    setState(() {
      completed[index] = !completed[index];
    });
    saveTasks();
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Add Task'),
                    content: TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        hintText: 'Enter task...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          taskController.clear();
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          addTask();
                          Navigator.pop(context);
                        },
                        child: Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [

          SizedBox(height: 10),

          // Task count row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tasks: ${tasks.length}',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
                Text(
                  'Done: ${completed.where((e) => e).length}',
                  style: TextStyle(fontSize: 15, color: Colors.green),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt,
                      size: 60, color: Colors.grey.shade300),
                  SizedBox(height: 10),
                  Text(
                    'No tasks added yet',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Tap + to add a task',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        completed[index]
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: completed[index]
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: () => toggleComplete(index),
                    ),
                    title: Text(
                      tasks[index],
                      style: TextStyle(
                        fontSize: 15,
                        color: completed[index]
                            ? Colors.grey
                            : Colors.black,
                        decoration: completed[index]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      onPressed: () => deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}