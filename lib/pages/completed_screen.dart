import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import '../../services/todo_service.dart';
import '../../widgets/todo_item_widget.dart';
import 'todo_detail_screen.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  final TodoService _todoService = TodoService();
  List<Todo> _completedTodos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCompletedTodos();
  }

  Future<void> _loadCompletedTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await _todoService.getTodos();
      setState(() {
        _completedTodos = todos.where((todo) => todo.isCompleted).toList();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading completed todos: $error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Completed Tasks',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedTodos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No completed tasks yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Complete some tasks to see them here',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCompletedTodos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _completedTodos.length,
                    itemBuilder: (context, index) {
                      final todo = _completedTodos[index];
                      return TodoItemWidget(
                        todo: todo,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodoDetailScreen(todo: todo),
                            ),
                          );
                          _loadCompletedTodos();
                        },
                        onToggle: (isCompleted) async {
                          await _todoService.updateTodo(
                            todo.copyWith(isCompleted: isCompleted),
                          );
                          _loadCompletedTodos();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}