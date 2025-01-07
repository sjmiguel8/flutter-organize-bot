import 'package:flutter/material.dart';
import 'screens/second_page.dart';
import 'screens/chat_page.dart';
import 'models/task.dart';
import 'services/openai_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        cardTheme: const CardTheme(
          elevation: 8,
          color: Colors.white10,
        ),
      ),
      home: MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on home
        Navigator.pop(context);
        break;
      case 1:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
        break;
      case 2:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SecondPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(
        backgroundColor: Colors.black87,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 120, 24, 123),
            ),
            child: const Text(
              'Navigation Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.home, color: Colors.white),
            label: Text('Home', style: TextStyle(color: Colors.white)),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.chat, color: Colors.white),
            label: Text('Chat', style: TextStyle(color: Colors.white)),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.star, color: Colors.white),
            label: Text('Fun Page', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Counter button
          Expanded(
            flex: 1,
            child: const MyHomePage(
              title: 'Organize Bot',
            ),
          ),
          // Right side - Task tracker
          Expanded(
            flex: 1,
            child: TaskSection(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black54,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondPage()),
            );
          },
          child: Center(
            child: Text(
              'Next →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            text: message,
            isUser: true,
          ));
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final response = await _openAIService.getResponse(message);
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: response,
              isUser: false,
            ));
      });
    } catch (e) {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: 'Error: $e',
              isUser: false,
            ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startNewConversation() {
    setState(() {
      _messages.clear();
      _messages.insert(
        0,
        ChatMessage(
          text: "Hello! I'm your AI assistant. How can I help you today?",
          isUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(221, 0, 0, 0),
              const Color.fromARGB(221, 71, 71, 71),
            ],
          ),
        ),
        child: Column(
          children: [
            // Top section with cards
            Expanded(
              flex: 0,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                        // Your existing AI Powered App card
                        ),
                    Card(
                        // Your existing Push The Button card
                        ),
                    Card(
                        // Your existing Enter card
                        ),
                  ],
                ),
              ),
            ),
            // Bottom section with chat
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: message.isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 10.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: message.isUser
                                        ? Colors.deepPurple
                                        : Colors.grey[800],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    message.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                              ),
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () =>
                                _sendMessage(_messageController.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewConversation,
        backgroundColor: const Color.fromARGB(255, 120, 24, 123),
        label: const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'New Chat',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class MyCard extends StatelessWidget {
  const MyCard({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text('Hello'),
    );
  }
}

class TaskSection extends StatefulWidget {
  const TaskSection({super.key});

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask(String title) {
    if (title.isEmpty) return;
    setState(() {
      _tasks.add(Task(
        id: DateTime.now().toString(),
        title: title,
      ));
    });
    _taskController.clear();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  void _toggleTask(String id) {
    setState(() {
      final task = _tasks.firstWhere((task) => task.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _editTask(String id) {
    final task = _tasks.firstWhere((task) => task.id == id);
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController editController =
            TextEditingController(text: task.title);
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Edit task',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    task.title = editController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          Text(
            'Tasks',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter new task',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                          ),
                          onSubmitted: _addTask,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _addTask(_taskController.text),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        leading: IconButton(
                          icon: Icon(
                            task.isCompleted
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.white,
                          ),
                          onPressed: () => _toggleTask(task.id),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            color: Colors.white,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _editTask(task.id),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteTask(task.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
