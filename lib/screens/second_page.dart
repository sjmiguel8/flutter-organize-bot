import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  String _selectedAnalysis = 'Summarize';
  String _result = '';
  bool _isLoading = false;

  final List<String> _analysisOptions = [
    'Summarize',
    'Key Points',
    'Pros and Cons',
    'Expand',
  ];

  Future<void> _analyzeText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await _openAIService.getResponse(_textController.text);
      setState(() {
        _result = response;
      });
    } catch (e) {
      print('Error in _analyzeText: $e');
      setState(() {
        _result = 'Error analyzing text: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Document Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              kToolbarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(221, 0, 0, 0),
                Color.fromARGB(221, 71, 71, 71),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Input Section - Make it smaller and more compact
                SizedBox(
                  height: 240,
                  child: Card(
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _textController,
                            focusNode: _textFocusNode,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Paste your text here...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onTap: () {
                              if (!_textFocusNode.hasFocus) {
                                _textFocusNode.requestFocus();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          // Analysis Options Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedAnalysis,
                              isExpanded: true,
                              dropdownColor: const Color.fromARGB(221, 0, 0, 0),
                              style: const TextStyle(color: Colors.white),
                              underline: Container(),
                              items: _analysisOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedAnalysis = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _textFocusNode.unfocus();
                              _analyzeText();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 120, 24, 123),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Analyze',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Results Section
                Expanded(
                  child: Card(
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Text(
                                _result.isEmpty
                                    ? 'Analysis results will appear here'
                                    : _result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
