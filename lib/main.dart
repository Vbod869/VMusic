import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/music_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V-Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.orange, // Accent color for buttons and highlights
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold), // AppBar title
          bodyMedium: TextStyle(fontSize: 16), // Default text style
        ),
      ),
      home: ChangeNotifierProvider(
        create: (context) => MusicProvider(),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final int _pageCount = 4; // Number of pages/images
  final Duration _duration = Duration(seconds: 3); // Duration of each slide

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(_duration, (Timer timer) {
        if (_pageController.hasClients) {
          final nextPage = (_pageController.page?.toInt() ?? 0 + 1) % _pageCount;
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('V-Music'),
        centerTitle: true,
        elevation: 4.0, // Adds a shadow below the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Ensure children take full width
          children: [
            // Image carousel at the top
            Container(
              height: 250, // Adjust the height as needed
              child: PageView(
                controller: _pageController,
                children: [
                  Image.asset('images/alan.jpeg', fit: BoxFit.cover),
                  Image.asset('images/op.jpeg', fit: BoxFit.cover),
                  Image.asset('images/mars.jpeg', fit: BoxFit.cover),
                  Image.asset('images/meow.jpeg', fit: BoxFit.cover),
                ],
              ),
            ),
            SizedBox(height: 16.0), // Add spacing between carousel and search field
            // Search TextField
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for songs...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200], // Light background color for the TextField
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) {
                  musicProvider.searchSongs(query);
                },
              ),
            ),
            // Song List
            Expanded(
              child: Consumer<MusicProvider>(
                builder: (context, provider, child) {
                  if (provider.isSearching) {
                    return Center(child: CircularProgressIndicator());
                  } else if (provider.songs.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    return ListView.builder(
                      itemCount: provider.songs.length,
                      itemBuilder: (context, index) {
                        final song = provider.songs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: 4.0, // Adds shadow around the Card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                song.albumCover,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image, size: 60);
                                },
                              ),
                            ),
                            title: Text(song.title,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(song.artist),
                            trailing: IconButton(
                              icon: Icon(
                                provider.currentSong == song && provider.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                if (provider.currentSong == song &&
                                    provider.isPlaying) {
                                  provider.stopSong();
                                } else {
                                  provider.playSong(song);
                                }
                              },
                            ),
                            onTap: () {
                              if (provider.currentSong == song &&
                                  provider.isPlaying) {
                                provider.stopSong();
                              } else {
                                provider.playSong(song);
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
