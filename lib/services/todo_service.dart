import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/model/todo.dart';

class TodoService {
  final supabase = Supabase.instance.client;

  Future<List<Todo>> getTodos() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw 'User not authenticated';

    final response = await supabase
        .from('todos')
        .select()
        .eq('user_id', userId)
        .order('deadline', ascending: true);

    return (response as List).map((json) => Todo.fromJson(json)).toList();
  }

  Future<Todo> addTodo(Todo todo) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw 'User not authenticated';

    final todoData = todo.toJson();
    todoData['user_id'] = userId;

    final response = await supabase
        .from('todos')
        .insert(todoData)
        .select()
        .single();

    return Todo.fromJson(response);
  }

  Future<void> updateTodo(Todo todo) async {
    if (todo.id == null) throw 'Todo ID cannot be null';

    await supabase
        .from('todos')
        .update(todo.toJson())
        .eq('id', todo.id!);
  }

  Future<void> deleteTodo(int id) async {
    await supabase
        .from('todos')
        .delete()
        .eq('id', id);
  }
}
