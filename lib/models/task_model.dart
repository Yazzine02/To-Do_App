import 'dart:convert';

// Class that will be the Model for a Task Object
class TaskModel {
  //PROPERTIES
  final String id;
  String title;
  bool isCompleted;
  //CONSTRUCTOR
  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
  //METHODS
  //overriding the toString() method for a customized string representation of a task
  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
  //toMap() method to convert a task into a map that has keys as String and values any type (Dynamic)
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  //The fromMap factory constructor allows creating a TaskModel object from a Map.
  //The factory keyword indicates that this constructor might return a new instance or an existing instance.
  //It takes a Map with keys id, title, and isCompleted, and returns a TaskModel object with these properties.
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
    );
  }
  //This method converts the TaskModel object into a JSON string.
  //It first converts the object to a Map using the toMap() method and then encodes it into a JSON string using json.encode.
  String toJson() => json.encode(toMap());
  //This factory constructor creates a TaskModel object from a JSON string.
  //It first decodes the JSON string into a Map using json.decode and then calls the fromMap factory constructor to create a TaskModel object.
  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
