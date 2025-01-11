import 'package:flutter/material.dart';
import 'screens/second_page.dart';
import 'screens/chat_page.dart';
import 'models/task.dart';
import 'services/openai_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/third_page.dart';
import 'screens/emotion_analysis_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const MainLayout(),
        '/emotions': (context) => EmotionAnalysisScreen(),
      },
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
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
      case 3:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmotionAnalysisScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(
        backgroundColor: Colors.black87,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
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
          NavigationDrawerDestination(
            icon: Icon(Icons.face, color: Colors.white),
            label: Text('Emotion Analysis', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: const MyHomePage(title: 'Organize Bot'),
          ),
          Expanded(
            flex: 1,
            child: TaskSection(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
              child: Text('Next →'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThirdPage()),
                );
              },
              child: Text('3'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmotionAnalysisScreen()),
                );
              },
              child: Text('Emotions'),
            ),
          ],
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
        ),
      );
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
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: 'Error: $e',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
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
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
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

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blue : Colors.grey[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteTask(task.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a task',
                      border: OutlineInputBorder(),
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
        ],
      ),
    );
  }
}
