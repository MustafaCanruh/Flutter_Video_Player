import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Oynatıcı Ödevi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _isLooping = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
      _controller.setLooping(_isLooping);
    });
  }

  void _seekRelative(int seconds) {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;

    Duration newPosition = currentPosition + Duration(seconds: seconds);

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > duration) {
      newPosition = duration;
    }

    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Video Ödevi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller),
                        _controller.value.isPlaying
                            ? const SizedBox.shrink()
                            : Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text("Hata: Video yüklenemedi")),
                  );
                } else {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_controller.value.position)),
                      Text(_formatDuration(_controller.value.duration)),
                    ],
                  ),
                  Slider(
                    value: _controller.value.position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _controller.value.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _controller.seekTo(Duration(seconds: value.toInt()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 15,
              runSpacing: 15, // Dikey boşluk (sığmazsa alt satıra geçer)
              alignment: WrapAlignment.center,
              children: [
                // 10 Saniye Geri Sar
                IconButton.filledTonal(
                  onPressed: () => _seekRelative(-10),
                  icon: const Icon(Icons.replay_10),
                  tooltip: "10 Sn Geri",
                ),

                // Oynat / Duraklat
                IconButton.filled(
                  style: IconButton.styleFrom(iconSize: 32),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  tooltip: _controller.value.isPlaying ? "Duraklat" : "Oynat",
                ),

                // 10 Saniye İleri Sar
                IconButton.filledTonal(
                  onPressed: () => _seekRelative(10),
                  icon: const Icon(Icons.forward_10),
                  tooltip: "10 Sn İleri",
                ),

                // Ses Aç / Kapa (Mute)
                IconButton.outlined(
                  onPressed: _toggleMute,
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: _isMuted ? Colors.red : null, // Mute iken kırmızı
                  ),
                  tooltip: "Sesi Kapat/Aç",
                ),

                // Döngü (Loop)
                IconButton.outlined(
                  onPressed: _toggleLoop,
                  icon: Icon(
                    Icons.loop,
                    color: _isLooping
                        ? Colors.green
                        : Colors.grey, // Aktifken yeşil
                  ),
                  tooltip: "Döngüye Al",
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Alt bilgi (İsteğe bağlı)
            const Text(
              "Kullanıcı Etkileşimli Video Oynatıcı",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
