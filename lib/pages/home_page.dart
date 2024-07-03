import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //TASK MANIPULATION
  //TaskList variable that will store our tasks
  List<TaskModel> tasksList = [];
  //task methods for creating, updating and deleting
  void createTask({required TaskModel task}) {
    setState(() {
      tasksList.add(task);
      saveOnLocalStorage();
      print("Task created successfully.");
    });
  }

  void updateTask({required String taskId, required TaskModel newTask}) {
    setState(() {
      if (tasksList.isEmpty) {
        print("Cannot update on an empty list of tasks.");
        return;
      }
      final oldTaskIndex = tasksList.indexWhere((task) => task.id == taskId);
      tasksList[oldTaskIndex] = newTask;
      saveOnLocalStorage();
      print("Task updated successfully.");
    });
  }

  void deleteTask({required String taskId}) {
    setState(() {
      if (tasksList.isEmpty) {
        print("Cannot delete on an empty list of tasks.");
        return;
      }
      final taskIndex = tasksList.indexWhere((task) => task.id == taskId);
      tasksList.removeAt(taskIndex);
      saveOnLocalStorage();
    });
  }

  //VARIABLES
  //variable for the text input field that we will use later
  final TextEditingController textEditingController = TextEditingController();
  //variable to perform SharedPreferences actions (for cache and constant save)
  SharedPreferences? sharedPreferences;

  //SHAREDPREFERENCES METHODS
  //saving tasks to local storage
  void saveOnLocalStorage(){
    final taskData = tasksList.map((task)=>task.toJson()).toList();
    sharedPreferences?.setStringList('tasks', taskData);
  }
  //reading from local storage
  //i have no idea how this works
  void readFromLocalStorage(){
    setState(() {
      final taskData = sharedPreferences?.getStringList('tasks') ?? [];
      tasksList= taskData.map((taskJson)=>TaskModel.fromJson(taskJson)).toList();
    });
  }
  // Function that is called whenever our widget is rebuilt
  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  // Initializes SharedPreferences for use
  void initPrefs () async {
    sharedPreferences = await SharedPreferences.getInstance();
    readFromLocalStorage();
  }
  //HOMEPAGE STRUCTURING AND BUILDING
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('My To-Do List'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        //Displaying task list only if there is at least one item on the list
        child: tasksList.isNotEmpty
            ? Column(
                children: [
                  // Widget for the task list that displays when there is at least one item
                  // We will use a Expanded widget so that it takes as much space as needed
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ListView.builder(
                        itemCount: tasksList.length,
                        itemBuilder: (context, index) {
                          // Retrieving task from index
                          final TaskModel task = tasksList[index];
                          return ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                  //styling the tasks depending on state
                                  color: task.isCompleted
                                      ? Colors.grey
                                      : Colors.black,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontSize: 20),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  deleteTask(taskId: task.id);
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent, size: 30)),
                            leading: Transform.scale(
                              scale: 2.0,
                              child: Checkbox(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                value: task.isCompleted,
                                onChanged: (isChecked) {
                                  // Updates the tasks state when checking or unchecking the CheckBox.
                                  final TaskModel updatedTask = task;
                                  updatedTask.isCompleted = isChecked!;
                                  updateTask(
                                    taskId: updatedTask.id,
                                    newTask: updatedTask,
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                  ))
                ],
                //this is what displays when there is no item on the list
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: const Text(
                    "No tasks registered. Tap on the + symbol to add a new task",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Show the task addition dialog
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add New Task'),
                  content: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.add),
                        labelText: 'Describe your task.'),
                    maxLines: 2,
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          //If there is info typed in
                          if (textEditingController.text.isNotEmpty) {
                            final TaskModel newTask = TaskModel(
                                id: DateTime.now().toString(),
                                title: textEditingController.text);
                            createTask(task: newTask);
                            //clearing input field
                            textEditingController.clear();
                            //closing dialog popup
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Save"))
                  ],
                );
              });
        },
      ),
    );
  }
}
