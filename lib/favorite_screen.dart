import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FavoriteUrl {
  late String _alias;
  final String url;

  FavoriteUrl({
    required String alias,
    required this.url,
  }) : _alias = alias;

  String get alias => _alias;

  set alias(String newAlias) {
    _alias = newAlias;
  }
}

class FavoritesScreen extends StatefulWidget {
  final List<FavoriteUrl> favoriteUrls;

  const FavoritesScreen({Key? key, required this.favoriteUrls})
      : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  void removeFromFavorites(FavoriteUrl favoriteUrl) {
    setState(() {
      widget.favoriteUrls.remove(favoriteUrl);
    });
  }

  void openURLInBrowser(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void editFavoriteAlias(FavoriteUrl favoriteUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newAlias = favoriteUrl.alias;
        return AlertDialog(
          title: const Text('Edit Alias'),
          content: TextField(
            onChanged: (value) {
              newAlias = value;
            },
            decoration: const InputDecoration(hintText: 'New Alias'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  favoriteUrl.alias = newAlias;
                });
                Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ListView.builder(
        itemCount: widget.favoriteUrls.length,
        itemBuilder: (context, index) {
          final favoriteUrl = widget.favoriteUrls[index];
          return ListTile(
            title: Text(favoriteUrl.alias),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    removeFromFavorites(favoriteUrl);
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    openURLInBrowser(favoriteUrl.url);
                  },
                  icon: const Icon(Icons.launch),
                ),
                IconButton(
                  onPressed: () {
                    editFavoriteAlias(favoriteUrl);
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

