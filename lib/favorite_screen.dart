import 'package:flutter/material.dart';
import 'package:mobile_sq_scanner/db/databasehelper.dart';
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
  final List<FavoriteRecord> favoriteUrlsRecords;

  const FavoritesScreen({Key? key, required this.favoriteUrlsRecords})
      : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final dbHelper = DatabaseHelper();

  void removeFromFavorites(FavoriteRecord record) async {
    await dbHelper.deleteFavoriteUrl(record.id);

    setState(() {
      widget.favoriteUrlsRecords.remove(record);
    });
  }

  void openURLInBrowser(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void editFavoriteAlias(FavoriteRecord record) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newAlias = record.alias;
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
              onPressed: () async {
                final currentContext = context;
                await dbHelper.updateFavoriteUrlAlias(record.id, newAlias);

                setState(() {
                  record.alias = newAlias;
                });
                Navigator.of(currentContext).pop();
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
        itemCount: widget.favoriteUrlsRecords.length,
        itemBuilder: (context, index) {
          final favoriteUrl = widget.favoriteUrlsRecords[index];
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

