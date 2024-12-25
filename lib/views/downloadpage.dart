import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:xupstore/provider/DownloadPP/download_button_provider.dart';
import 'package:xupstore/services/firestore_downloadpage_services.dart';
import 'package:xupstore/services/firestore_favourite_games_services.dart';

import '../provider/DownloadPP/game_rating_provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key, required this.game, required this.userid});

  final Map<String, dynamic> game;
  final String userid;

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  FirestoreDownloadpageServices firestoreDownloadpageServices =
      FirestoreDownloadpageServices();
  FirestoreFavouriteGamesServices firestoreFavouriteGamesServices =
      FirestoreFavouriteGamesServices();
  bool isFavorite = false;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  double rated = 0.0;
  final TextEditingController _reviewcontroller = TextEditingController();

  Future<void> downloadAndInstallAPK(
      BuildContext context, DownloadProvider downloadProvider) async {
    // Check and request permission for Install from Unknown Sources
    bool canInstallUnknownSources =
        await Permission.requestInstallPackages.isGranted;

    if (!canInstallUnknownSources) {
      // Prompt the user to enable "Install from Unknown Sources"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please enable "Install from Unknown Sources" to proceed with installation.'),
          action: SnackBarAction(
            label: 'Enable',
            onPressed: () async {
              await openUnknownSourcesSettings();

              // Recheck the permission after returning
              if (await Permission.requestInstallPackages.isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Permission granted. You can now install apps.'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permission not granted.')),
                );
              }
            },
          ),
        ),
      );
      return; // Exit if the permission is not granted
    }

    // Handle storage permissions
    PermissionStatus storageStatus;
    if (Platform.isAndroid) {
      // Handle storage permissions for Android 11+ using manageExternalStorage
      if (await Permission.manageExternalStorage.isGranted) {
        storageStatus = PermissionStatus.granted;
      } else {
        storageStatus = await Permission.manageExternalStorage.request();
      }
    } else {
      // For non-Android platforms, fallback to storage permission
      storageStatus = await Permission.storage.request();
    }

    if (storageStatus.isGranted) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${widget.game['title']}.apk';

      // Start downloading
      downloadProvider.startDownloading();

      try {
        await Dio().download(
          widget.game['apkFileUrl'],
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = received / total;
              downloadProvider.updateProgress(progress);
            }
          },
        );

        downloadProvider.finishDownloading();

        // Directly open the APK file for installation
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open the APK file for installation.'),
            ),
          );
        }
      } catch (e) {
        downloadProvider.finishDownloading();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download the APK. Please try again.'),
          ),
        );
      }
    } else if (storageStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Storage permission is permanently denied. Please enable it in settings.'),
        ),
      );
      openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to download the APK.'),
        ),
      );
    }
  }

  Future<void> openUnknownSourcesSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
        data: 'package:${(await PackageInfo.fromPlatform()).packageName}',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }

  @override
  void initState() {
    super.initState();
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    ratingProvider.fetchRatingAndReviewCount(widget.game['gameid']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.grey.shade500,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.share,
                      color: Colors.grey.shade500,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Hero(
                      tag: 'img',
                      child: Image.network(
                        widget.game['gameImagesList'][0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.game['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     isFavorite ? Icons.favorite : Icons.favorite_border,
                    //     color: isFavorite ? Colors.red : Colors.grey,
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       isFavorite = !isFavorite;
                    //     });
                    //   },
                    // ),
                    // FavoriteButton(FirebaseAuth.instance.currentUser!.uid,
                    //     widget.game['gameid'])

                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final docData =
                            snapshot.data?.data() as Map<String, dynamic>? ??
                                {};
                        final favorites =
                            List<String>.from(docData['favorites'] ?? []);
                        final isFavorite =
                            favorites.contains(widget.game['gameid']);

                        String userId = FirebaseAuth.instance.currentUser!.uid;
                        String gameId = widget.game['gameid'];

                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isFavorite ? Colors.red : Colors.grey,
                          onPressed: () {
                            if (isFavorite) {
                              firestoreFavouriteGamesServices.removeFavorite(
                                  userId, gameId);
                            } else {
                              firestoreFavouriteGamesServices.addFavorite(
                                  userId, gameId);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  widget.game['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 15),
                Consumer<RatingProvider>(
                  builder: (context, ratingProvider, child) {
                    if (ratingProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xffe0d910),
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          ratingProvider.averageRating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${ratingProvider.reviewCount} reviews",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 15),
                Consumer<RatingProvider>(
                  builder: (context, ratingProvider, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          itemSize: 30,
                          initialRating: ratingProvider.rated,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Color(0xffe0d910),
                          ),
                          onRatingUpdate: (rating) {
                            // Update rating using the provider, no need for setState
                            ratingProvider.updateRating(rating);
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Post a Review",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewcontroller,
                  decoration: InputDecoration(
                    hintText: 'Write your review here...',
                    hintStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                      borderSide: BorderSide.none, // Remove the visible border
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[200], // Light background color
                  ),
                  maxLines: null,
                  style: const TextStyle(
                      fontSize:
                          16), // Optional: adjust font size for readability
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Consumer<RatingProvider>(
                    builder: (context, ratingProvider, child) {
                      return ElevatedButton(
                        onPressed: () async {
                          await ratingProvider.addReview(
                            gameId: widget.game['gameid'],
                            rating: ratingProvider.rated,
                            reviewText: _reviewcontroller.text.trim(),
                          );
                          _reviewcontroller.clear();

                          ratingProvider
                              .fetchRatingAndReviewCount(widget.game['gameid']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6d72ea),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestoreDownloadpageServices
                      .getReviewsStream(widget.game['gameid']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No reviews yet."));
                    }

                    final reviews = snapshot.data!;

                    return ListView.builder(
                      itemCount: reviews.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final username = review['username'] ?? 'Anonymous';
                        final rating = review['rating'] ?? 0.0;
                        final reviewText = review['reviewText'] ?? '';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    RatingBar.builder(
                                      itemSize: 20,
                                      initialRating: rating.toDouble(),
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Color(0xffe0d910),
                                      ),
                                      onRatingUpdate: (rating) {
                                        // Do nothing, as this is just for display
                                      },
                                      ignoreGestures:
                                          true, // Makes the RatingBar non-interactive
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      reviewText,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Consumer<DownloadProvider>(
              builder: (context, downloadProvider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6d72ea),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  onPressed: downloadProvider.isDownloading
                      ? null
                      : () async {
                          // Start downloading and installation logic
                          await downloadAndInstallAPK(
                              context, downloadProvider);
                        },
                  child: downloadProvider.isDownloading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value: downloadProvider.downloadProgress,
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Downloading... ${(downloadProvider.downloadProgress * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Download and Install',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}




// Future<void> downloadAndInstallAPK(
//       BuildContext context, DownloadProvider downloadProvider) async {
//     // Request storage permission
//     PermissionStatus storageStatus = await Permission.storage.request();

//     if (storageStatus.isGranted) {
//       final directory = await getTemporaryDirectory();
//       final filePath = '${directory.path}/${widget.game['title']}.apk';

//       // Start downloading
//       downloadProvider.startDownloading();

//       try {
//         await Dio().download(
//           widget.game['apkFileUrl'],
//           filePath,
//           onReceiveProgress: (received, total) {
//             if (total != -1) {
//               double progress = received / total;
//               downloadProvider.updateProgress(progress);
//             }
//           },
//         );

//         downloadProvider.finishDownloading();

//         // Check if Install from Unknown Sources is enabled
//         bool canInstallUnknownSources =
//             await Permission.requestInstallPackages.isGranted;
//         if (!canInstallUnknownSources) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   'Please enable "Install from Unknown Sources" to continue.'),
//               action: SnackBarAction(
//                 label: 'Enable',
//                 onPressed: () => openUnknownSourcesSettings(),
//               ),
//             ),
//           );
//         } else {
//           OpenFile.open(filePath);
//         }
//       } catch (e) {
//         downloadProvider.finishDownloading();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Failed to download the APK. Please try again.')),
//         );
//       }
//     } else if (storageStatus.isPermanentlyDenied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Storage permission is permanently denied. Please enable it in settings.'),
//         ),
//       );
//       openAppSettings();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content:
//                 Text('Storage permission is required to download the APK.')),
//       );
//     }
//   }

//   Future<void> openUnknownSourcesSettings() async {
//     if (Platform.isAndroid) {
//       final intent = AndroidIntent(
//         action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
//         data: 'package:${(await PackageInfo.fromPlatform()).packageName}',
//         flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
//       );
//       await intent.launch();
//     }
//   }






// Future<void> downloadAndInstallAPK(
//       BuildContext context, DownloadProvider downloadProvider) async {
//     // Check and request permission for Install from Unknown Sources
//     bool canInstallUnknownSources =
//         await Permission.requestInstallPackages.isGranted;

//     if (!canInstallUnknownSources) {
//       // Prompt the user to enable "Install from Unknown Sources"
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Please enable "Install from Unknown Sources" to proceed with installation.'),
//           action: SnackBarAction(
//             label: 'Enable',
//             onPressed: () async {
//               await openUnknownSourcesSettings();

//               // Recheck the permission after returning
//               if (await Permission.requestInstallPackages.isGranted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content:
//                         Text('Permission granted. You can now install apps.'),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Permission not granted.')),
//                 );
//               }
//             },
//           ),
//         ),
//       );
//       return; // Exit if the permission is not granted
//     }

//     // Request storage permission
//     PermissionStatus storageStatus = await Permission.storage.request();

//     if (storageStatus.isGranted) {
//       final directory = await getTemporaryDirectory();
//       final filePath = '${directory.path}/${widget.game['title']}.apk';

//       // Start downloading
//       downloadProvider.startDownloading();

//       try {
//         await Dio().download(
//           widget.game['apkFileUrl'],
//           filePath,
//           onReceiveProgress: (received, total) {
//             if (total != -1) {
//               double progress = received / total;
//               downloadProvider.updateProgress(progress);
//             }
//           },
//         );

//         downloadProvider.finishDownloading();

//         // Directly open installation after download
//         OpenFile.open(filePath);
//       } catch (e) {
//         downloadProvider.finishDownloading();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Failed to download the APK. Please try again.')),
//         );
//       }
//     } else if (storageStatus.isPermanentlyDenied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Storage permission is permanently denied. Please enable it in settings.'),
//         ),
//       );
//       openAppSettings();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content:
//                 Text('Storage permission is required to download the APK.')),
//       );
//     }
//   }