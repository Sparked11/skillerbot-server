import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:confetti/confetti.dart';
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

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.drill.videoUrl);
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _confettiController?.dispose();
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
        SnackBar(content: Text("✅ Submitted: ${_videoFile!.name}, +$points SkillerPoints!")),
      );
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70))),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YoutubePlayer(controller: _youtubeController),
                  const SizedBox(height: 20),
                  _buildInfoRow("Level", widget.drill.level),
                  _buildInfoRow("Materials", widget.drill.materials),
                  _buildInfoRow("Duration", widget.drill.duration),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(widget.drill.description, style: const TextStyle(fontSize: 15, color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Your Completion Video"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                  ),
                  const SizedBox(height: 10),
                  if (_videoFile != null)
                    Text("Selected: ${_videoFile!.name}", style: const TextStyle(color: Colors.white70)),
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
              colors: const [Colors.green, Colors.blue, Colors.yellow, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }
}
