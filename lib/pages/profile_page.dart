import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/database/profile_databse.dart';
import 'package:project/pages/login_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isMyVideosSelected = true;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addVideo() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Video'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Video Title'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'YouTube URL'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a URL';
                  }
                  final videoId = YoutubePlayer.convertUrlToId(value!);
                  if (videoId == null) {
                    return 'Please enter a valid YouTube URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                await ProfileDatabse.instance.insertVideo({
                  'title': _titleController.text,
                  'videoUrl': _urlController.text,
                  'userEmail': currentUser?.email,
                  'dateAdded': DateTime.now().toIso8601String(),
                });
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                _titleController.clear();
                _urlController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _isMyVideosSelected
          ? ProfileDatabse.instance.getUserVideos(currentUser?.email ?? '')
          : ProfileDatabse.instance.getFavorites(currentUser?.email ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(_isMyVideosSelected
                ? 'No videos added yet'
                : 'No favorite videos yet'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final video = snapshot.data![index];
            return Card(
              child: ListTile(
                title: Text(video['title']),
                subtitle: Text(_isMyVideosSelected
                    ? 'Added by: ${video['userEmail']}'
                    : 'Added to favorites'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isMyVideosSelected) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editVideo(video),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        if (_isMyVideosSelected) {
                          await ProfileDatabse.instance
                              .deleteVideo(video['id'] as int);
                        } else {
                          await ProfileDatabse.instance.deleteFavorite(
                              video['movieId'] as int, currentUser?.email ?? '');
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editVideo(Map<String, dynamic> video) async {
    _titleController.text = video['title'];
    _urlController.text = video['videoUrl'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Video'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Video Title'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'YouTube URL'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a URL';
                  }
                  final videoId = YoutubePlayer.convertUrlToId(value!);
                  if (videoId == null) {
                    return 'Please enter a valid YouTube URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                await ProfileDatabse.instance.updateVideo({
                  'id': video['id'],
                  'title': _titleController.text,
                  'videoUrl': _urlController.text,
                  'userEmail': currentUser?.email,
                  'dateAdded': DateTime.now().toIso8601String(),
                });
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                _titleController.clear();
                _urlController.clear();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile - ${currentUser?.email ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => const LoginPage()
                )
              );
            },
          ),
        ],
      ),
      body: Column(
  children: [
    Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _isMyVideosSelected = true),
            style: ButtonStyle(
              backgroundColor: ButtonStyleButton.allOrNull<Color>(
                _isMyVideosSelected ? Colors.blue : Colors.grey[200],
              ),
            ),
            child: Text(
              'My Videos', 
              style: TextStyle(
                color: _isMyVideosSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _isMyVideosSelected = false),
            style: ButtonStyle(
              backgroundColor: ButtonStyleButton.allOrNull<Color>(
                !_isMyVideosSelected ? Colors.blue : Colors.grey[200],
              ),
            ),
            child: Text(
              'Favorite Videos',
              style: TextStyle(
                color: !_isMyVideosSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
    Expanded(child: _buildVideoList()),
  ],
),
      floatingActionButton: _isMyVideosSelected
          ? FloatingActionButton(
              onPressed: _addVideo,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}