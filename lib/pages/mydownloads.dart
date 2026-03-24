import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/widget/mytext.dart';
import '../model/download_item.dart';
import '../players/player_video.dart';
import '../utils/sharedpre.dart';

class MyDownloads extends StatefulWidget {
  const MyDownloads({super.key});

  @override
  State<MyDownloads> createState() => _MyDownloadsState();
}

class _MyDownloadsState extends State<MyDownloads> {
  Box<DownloadItem>? downloadBox;

  Future<Box<DownloadItem>> _openBox() async {
    // Wait for userID to be ready
    if (Constant.userID == null) {
      Constant.userID = await SharedPre().read("userid");
      if (Constant.userID == null) {
        // Retry once after slight delay
        await Future.delayed(const Duration(milliseconds: 200));
        Constant.userID = await SharedPre().read("userid");
      }
    }

    final boxName = '${Constant.hiveDownloadBox}_${Constant.userID}';

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<DownloadItem>(boxName);
    }

    return Hive.box<DownloadItem>(boxName);
  }

  Future<void> _openDownloadedVideo(DownloadItem item) async {
    if (item.savedFile == null || item.savedFile!.isEmpty) {
      Utils().showSnackBar(context, "Video file not found.", false);
      return;
    }

    final file = File(item.savedFile!);
    if (!file.existsSync()) {
      Utils().showSnackBar(context, "Video not available locally.", false);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerVideo(
          videoId: item.id.toString(),
          videoUrl: item.savedFile!,
          videoThumb: item.landscapeImg ?? item.portraitImg,
          stoptime: (item.stopTime ?? 0).toDouble(),
          iscontinueWatching: true,
          isDownloadVideo: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils().otherPageAppBar(context, "download", true),
      backgroundColor: appbgcolor,
      body: FutureBuilder<Box<DownloadItem>>(
        future: _openBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load downloads."));
          }

          final box = snapshot.data!;
          if (box.isEmpty) {
            return Center(
              child: MyText(
                text: "No downloads found.",
                color: white,
                multilanguage: false,
                fontsizeNormal: 16,
              ),
            );
          }

          return ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<DownloadItem> box, _) {
              final items = box.values.toList().reversed.toList();

              return ListView.builder(
                itemCount: items.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: (item.landscapeImg?.isNotEmpty ?? false)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(item.landscapeImg!),
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.white),
                              ),
                            )
                          : const Icon(Icons.movie,
                              color: Colors.white, size: 50),
                      title: MyText(
                        text: item.title ?? "Untitled Video",
                        color: white,
                        fontwaight: FontWeight.w600,
                        maxline: 2,
                        multilanguage: false,
                      ),
                      subtitle: MyText(
                        text: item.channelName ?? "",
                        color: Colors.grey,
                        fontsizeNormal: 12,
                        multilanguage: false,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async => await _deleteDownload(item),
                      ),
                      onTap: () => _openDownloadedVideo(item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteDownload(DownloadItem item) async {
    try {
      if (item.savedFile != null && item.savedFile!.isNotEmpty) {
        final file = File(item.savedFile!);
        if (file.existsSync()) file.deleteSync();
      }

      if (item.landscapeImg != null && item.landscapeImg!.isNotEmpty) {
        final img = File(item.landscapeImg!);
        if (img.existsSync()) img.deleteSync();
      }

      if (item.portraitImg != null && item.portraitImg!.isNotEmpty) {
        final img = File(item.portraitImg!);
        if (img.existsSync()) img.deleteSync();
      }

      final box = Hive.box<DownloadItem>(
        '${Constant.hiveDownloadBox}_${Constant.userID}',
      );
      final index = box.values.toList().indexOf(item);
      if (index != -1) await box.deleteAt(index);

      Utils().showSnackBar(context, "Download deleted", false);
    } catch (e) {
      Utils().showSnackBar(context, "Failed to delete download", false);
    }
  }
}
