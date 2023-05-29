import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_sq_scanner/db/databasehelper.dart';
import 'package:mobile_sq_scanner/screens/favorite_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FoundCodeScreen extends StatefulWidget {
  final String value;
  final List<FavoriteRecord> listUrls;
  final Function() screenClosed;

  const FoundCodeScreen({
    Key? key,
    required this.value,
    required this.screenClosed,
    required this.listUrls,
  }) : super(key: key);

  @override
  State<FoundCodeScreen> createState() => _FoundCodeScreenState();
}

class _FoundCodeScreenState extends State<FoundCodeScreen> {
  bool isFavorite = false;

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void openURLInBrowser(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void addToFavorites(String url) async {
    FavoriteUrl favorite = FavoriteUrl(alias: Uri.parse(url).host, url: url);
    int id = await dbHelper.insertFavoriteUrl(favorite);

    setState(() {
      widget.listUrls
          .add(FavoriteRecord(id: id, alias: Uri.parse(url).host, url: url));
    });
  }

  void _initializeDatabase() async {
    await dbHelper.database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Found Code"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            widget.screenClosed();
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Scanned Code:",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  openURLInBrowser(widget.value);
                },
                child: const Text('Open URL'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  addToFavorites(widget.value);

                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: Text(
                  isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
