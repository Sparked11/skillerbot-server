import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/drill.dart';

class DrillDetailPage extends StatefulWidget {
  final Drill drill;
  final Function(int) onDrillSubmitted;

  const DrillDetailPage({
    Key? key,
    required this.drill,
    required this.onDrillSubmitted,
  }) : super(key: key);

  @override
  _DrillDetailPageState createState() => _DrillDetailPageState();
}

class _DrillDetailPageState extends State<DrillDetailPage> {
  late YoutubePlayerController _youtubeController;
  ConfettiController? _confettiController;
  PlatformFile? _videoFile;
  bool _hasSubmitted = false;

  // AI Integration
  final TextEditingController _questionController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.drill.videoUrl);
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _confettiController?.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = result.files.first;
      });

      _submitVideo();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No file selected.")),
      );
    }
  }

  void _submitVideo() {
    if (_videoFile != null && !_hasSubmitted) {
      _confettiController?.play();

      int points = 0;
      final difficulty = widget.drill.level.toLowerCase();
      if (difficulty.contains('easy')) {
        points = 10;
      } else if (difficulty.contains('intermediate')) {
        points = 15;
      } else if (difficulty.contains('hard')) {
        points = 20;
      }

      widget.onDrillSubmitted(points);

      setState(() {
        _hasSubmitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "✅ Submitted: ${_videoFile!.name}, +$points SkillerPoints!")),
      );
    }
  }

  Future<void> _askAI(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    try {
      final response = await http.post(
        Uri.parse("https://skillerbot-server-6.onrender.com/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': question}),
      );

      print('SkillerBot status: ${response.statusCode}');
      print('SkillerBot body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');
        setState(() {
          _aiResponse = data['reply'] ?? 'No response from SkillerBot.';
        });
      } else {
        // Show full response body for troubleshooting
        setState(() {
          _aiResponse =
              "❌ Error from SkillerBot.\nStatus code: ${response.statusCode}\nResponse: ${response.body}";
        });
      }
    } catch (e, st) {
      print('Error calling SkillerBot: $e');
      print(st);
      setState(() {
        _aiResponse = "❌ Failed to reach SkillerBot: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.drill.name),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YoutubePlayer(controller: _youtubeController),
                  const SizedBox(height: 20),
                  _buildInfoRow("Level", widget.drill.level),
                  _buildInfoRow("Materials", widget.drill.materials),
                  _buildInfoRow("Duration", widget.drill.duration),
                  const SizedBox(height: 20),
                  const Text("Description",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(widget.drill.description,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Your Completion Video"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent),
                  ),
                  const SizedBox(height: 10),
                  if (_videoFile != null)
                    Text("Selected: ${_videoFile!.name}",
                        style: const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 30),

                  // 🧠 AI Chat Section
                  const Text("Need Help? Ask SkillerBot!",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask how to do this drill better...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.lightBlueAccent),
                        onPressed: () => _askAI(_questionController.text),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (_aiResponse.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_aiResponse,
                          style: const TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController!,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.orange
              ],
            ),
          ),
        ],
      ),
    );
  }
}
