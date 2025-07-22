import 'dart:io';
import 'package:attendance_app/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:attendance_app/models/upload_entry.dart';
import 'package:attendance_app/database/upload_entry_db.dart';
import 'package:attendance_app/services/upload_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendance_app/providers/app_state_provider.dart';

class UploadDetailsScreen extends ConsumerStatefulWidget {
  final UploadEntry entry;

  const UploadDetailsScreen({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
}

class _UploadDetailsScreenState extends ConsumerState<UploadDetailsScreen> {
  File? _imageFile;
  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isSubmitting || _isFetchingLocation) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _fetchLocation() async {
    if (_isSubmitting || _isFetchingLocation) return;

    setState(() => _isFetchingLocation = true);
    final position = await getCurrentPosition();

    if (!mounted) return;

    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } else {
      _showSnackbar("❌ Failed to fetch location");
    }

    if (mounted) {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _submit() async {
    final now = DateTime.now();
    final userId = ref.read(appStateProvider).userId;
    final token = ref.read(appStateProvider).authToken;

    if (userId == null || token == null) {
      _showSnackbar("❌ UserId or token missing.");
      return;
    }

    if (now.isAfter(widget.entry.slotEnd)) {
      _showSnackbar("❌ Upload window expired");
      return;
    }

    if (_imageFile == null || _latitude == null || _longitude == null) {
      _showSnackbar("⚠️ Please select image and fetch location");
      return;
    }

    setState(() => _isSubmitting = true);
    _showSnackbar("⏳ Uploading entry...");

    try {
      final success = await UploadService.uploadEntry(
        imageFile: _imageFile!,
        latitude: _latitude!,
        longitude: _longitude!,
        timeSlot: widget.entry.slotStart,
        token: token,
        userId: userId, // ✅ pass userId here
      );

      if (!success) {
        _showSnackbar("❌ Upload failed. Try again.");
        return;
      }

      final updatedEntry = widget.entry.copyWith(
        imagePath: _imageFile!.path,
        latitude: _latitude!,
        longitude: _longitude!,
        status: 'done',
        isSynced: true,
      );

      await UploadEntryDB().updateEntry(updatedEntry);

      _showSnackbar("✅ Upload successful");

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackbar("❌ Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 15)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSubmitting || _isFetchingLocation;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload: ${widget.entry.slotLabel}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1B23),
              Color(0xFF2D2E3F),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Section
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2E3F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _imageFile!,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No image selected",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Take a photo to continue",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Camera Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: isBusy ? null : () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    "Take Photo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Location Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2E3F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: isBusy ? null : _fetchLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    _isFetchingLocation ? Icons.refresh : Icons.location_on,
                    color: const Color(0xFF4F46E5),
                    size: 24,
                  ),
                  label: Text(
                    _isFetchingLocation ? "Fetching..." : "Get Location",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Location Display
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Location Captured",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Lat: ${_latitude!.toStringAsFixed(6)}\nLng: ${_longitude!.toStringAsFixed(6)}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Submit Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: isBusy 
                      ? null 
                      : const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: isBusy ? const Color(0xFF374151) : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isBusy ? null : [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isBusy && _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Submitting...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          "Submit Entry",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'dart:io';
// import 'package:attendance_app/utils/location_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:attendance_app/models/upload_entry.dart';
// import 'package:attendance_app/database/upload_entry_db.dart';
// import 'package:attendance_app/services/upload_service.dart';

// class UploadDetailsScreen extends StatefulWidget {
//   final UploadEntry entry;
//   final String token;

//   const UploadDetailsScreen({
//     super.key,
//     required this.entry,
//     required this.token,
//   });

//   @override
//   State<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
// }

// class _UploadDetailsScreenState extends State<UploadDetailsScreen> {
//   File? _imageFile;
//   double? _latitude;
//   double? _longitude;

//   bool _isSubmitting = false;
//   bool _isFetchingLocation = false;

//   Future<void> _pickImage(ImageSource source) async {
//     if (_isSubmitting || _isFetchingLocation) return;

//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source);
//     if (picked != null) {
//       setState(() => _imageFile = File(picked.path));
//     }
//   }

//   Future<void> _fetchLocation() async {
//     if (_isSubmitting || _isFetchingLocation) return;

//     setState(() => _isFetchingLocation = true);
//     final position = await getCurrentPosition();

//     if (!mounted) return;

//     if (position != null) {
//       setState(() {
//         _latitude = position.latitude;
//         _longitude = position.longitude;
//       });
//     } else {
//       _showSnackbar("❌ Failed to fetch location");
//     }

//     if (mounted) {
//       setState(() => _isFetchingLocation = false);
//     }
//   }

//   Future<void> _submit() async {
//     final now = DateTime.now();

//     if (now.isAfter(widget.entry.slotEnd)) {
//       _showSnackbar("❌ Upload window expired");
//       return;
//     }

//     if (_imageFile == null || _latitude == null || _longitude == null) {
//       _showSnackbar("⚠️ Please select image and fetch location");
//       return;
//     }

//     setState(() => _isSubmitting = true);
//     _showSnackbar("⏳ Uploading entry...");

//     try {
//       final success = await UploadService.uploadEntry(
//         imageFile: _imageFile!,
//         latitude: _latitude!,
//         longitude: _longitude!,
//         timeSlot: widget.entry.slotStart, // Use `slotLabel` if your backend expects that
//         token: widget.token,
//       );

//       if (!success) {
//         _showSnackbar("❌ Upload failed. Try again.");
//         return;
//       }

//       final updatedEntry = widget.entry.copyWith(
//         imagePath: _imageFile!.path,
//         latitude: _latitude!,
//         longitude: _longitude!,
//         status: 'done',
//         isSynced: true,
//       );

//       await UploadEntryDB().updateEntry(updatedEntry);

//       _showSnackbar("✅ Upload successful");

//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       _showSnackbar("❌ Error: $e");
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(fontSize: 15)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isBusy = _isSubmitting || _isFetchingLocation;

//     return Scaffold(
//       appBar: AppBar(title: Text('Upload: ${widget.entry.slotLabel}')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _imageFile != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       _imageFile!,
//                       height: 220,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 : Container(
//                     height: 220,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     alignment: Alignment.center,
//                     child: const Text(
//                       "No image selected",
//                       style: TextStyle(color: Colors.black54),
//                     ),
//                   ),

//             const SizedBox(height: 16),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: isBusy ? null : () => _pickImage(ImageSource.camera),
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Camera"),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             ElevatedButton.icon(
//               onPressed: isBusy ? null : _fetchLocation,
//               icon: const Icon(Icons.location_on),
//               label: const Text("Fetch Location"),
//             ),

//             if (_latitude != null && _longitude != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: Text(
//                   "📍 Latitude: $_latitude\n📍 Longitude: $_longitude",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 14, color: Colors.black87),
//                 ),
//               ),

//             const Spacer(),

//             ElevatedButton(
//               onPressed: isBusy ? null : _submit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 disabledBackgroundColor: Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               child: isBusy && _isSubmitting
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         SizedBox(
//                           height: 22,
//                           width: 22,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Text("Submitting...", style: TextStyle(fontSize: 16)),
//                       ],
//                     )
//                   : const Text("Submit", style: TextStyle(fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// // import 'dart:io';
// // import 'package:attendance_app/utils/location_helper.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:intl/intl.dart';

// // import 'package:attendance_app/models/upload_entry.dart';
// // import 'package:attendance_app/database/upload_entry_db.dart';
// // import 'package:attendance_app/services/upload_service.dart';

// // class UploadDetailsScreen extends StatefulWidget {
// //   final UploadEntry entry;
// //   final String token;

// //   const UploadDetailsScreen({
// //     super.key,
// //     required this.entry,
// //     required this.token,
// //   });

// //   @override
// //   State<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
// // }

// // class _UploadDetailsScreenState extends State<UploadDetailsScreen> {
// //   File? _imageFile;
// //   double? _latitude;
// //   double? _longitude;

// //   bool _isSubmitting = false;
// //   bool _isFetchingLocation = false;

// //   Future<void> _pickImage(ImageSource source) async {
// //     if (_isSubmitting || _isFetchingLocation) return;

// //     final picker = ImagePicker();
// //     final picked = await picker.pickImage(source: source);
// //     if (picked != null) {
// //       setState(() {
// //         _imageFile = File(picked.path);
// //       });
// //     }
// //   }

// //   Future<void> _fetchLocation() async {
// //     if (_isSubmitting || _isFetchingLocation) return;

// //     setState(() => _isFetchingLocation = true);
// //     final position = await getCurrentPosition();

// //     if (!mounted) return;

// //     if (position != null) {
// //       setState(() {
// //         _latitude = position.latitude;
// //         _longitude = position.longitude;
// //       });
// //     } else {
// //       _showSnackbar("❌ Failed to fetch location");
// //     }

// //     if (mounted) {
// //       setState(() => _isFetchingLocation = false);
// //     }
// //   }

// //   Future<void> _submit() async {
// //     final now = DateTime.now();

// //     if (now.isAfter(widget.entry.slotEnd)) {
// //       _showSnackbar("❌ Upload window expired");
// //       return;
// //     }

// //     if (_imageFile == null || _latitude == null || _longitude == null) {
// //       _showSnackbar("⚠️ Please select image and fetch location");
// //       return;
// //     }

// //     setState(() => _isSubmitting = true);
// //     _showSnackbar("⏳ Checking your upload...");

// //     try {
// //       // Simulate upload delay and logic
// //       // final success = await UploadService.uploadEntry(...);
// //       await UploadEntryDB().updateEntry(updatedEntry);

// //             final success = await UploadService.uploadEntry(
// //               imageFile: _imageFile!,
// //               latitude: _latitude!,
// //               longitude: _longitude!,
// //               timeSlot: widget.entry.slotLabel,
// //               token: widget.token,
// //             );

// //             if (!success) {
// //               _showSnackbar("❌ Upload failed. Try again.");
// //               return;
// //             }

// //             final updatedEntry = widget.entry.copyWith(
// //               imagePath: _imageFile!.path,
// //               latitude: _latitude!,
// //               longitude: _longitude!,
// //               status: 'done',
// //               isSynced: true,
// //             );

// //             await UploadEntryDB().updateEntry(updatedEntry);

// //       _showSnackbar("✅ Upload successful");

// //       await Future.delayed(const Duration(seconds: 2));
// //       if (mounted) Navigator.pop(context);
// //     } catch (e) {
// //       _showSnackbar("❌ Error: $e");
// //     } finally {
// //       if (mounted) setState(() => _isSubmitting = false);
// //     }
// //   }

// //   void _showSnackbar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message, style: const TextStyle(fontSize: 15)),
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isBusy = _isSubmitting || _isFetchingLocation;

// //     return Scaffold(
// //       appBar: AppBar(title: Text('Upload: ${widget.entry.slotLabel}')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             _imageFile != null
// //                 ? ClipRRect(
// //                     borderRadius: BorderRadius.circular(8),
// //                     child: Image.file(
// //                       _imageFile!,
// //                       height: 220,
// //                       fit: BoxFit.cover,
// //                     ),
// //                   )
// //                 : Container(
// //                     height: 220,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[200],
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     alignment: Alignment.center,
// //                     child: const Text(
// //                       "No image selected",
// //                       style: TextStyle(color: Colors.black54),
// //                     ),
// //                   ),

// //             const SizedBox(height: 16),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 ElevatedButton.icon(
// //                   onPressed: isBusy
// //                       ? null
// //                       : () => _pickImage(ImageSource.camera),
// //                   icon: const Icon(Icons.camera_alt),
// //                   label: const Text("Camera"),
// //                 ),
// //                 // ElevatedButton.icon(
// //                 //   onPressed: isBusy
// //                 //       ? null
// //                 //       : () => _pickImage(ImageSource.gallery),
// //                 //   icon: const Icon(Icons.photo_library),
// //                 //   label: const Text("Gallery"),
// //                 // ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),
// //             ElevatedButton.icon(
// //               onPressed: isBusy ? null : _fetchLocation,
// //               icon: const Icon(Icons.location_on),
// //               label: const Text("Fetch Location"),
// //             ),

// //             if (_latitude != null && _longitude != null)
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 12),
// //                 child: Text(
// //                   "📍 Latitude: $_latitude\n📍 Longitude: $_longitude",
// //                   textAlign: TextAlign.center,
// //                   style: const TextStyle(fontSize: 14, color: Colors.black87),
// //                 ),
// //               ),

// //             const SizedBox(height: 24),

// //             ElevatedButton(
// //               onPressed: isBusy ? null : _submit,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.blue,
// //                 disabledBackgroundColor: Colors.grey,
// //                 padding: const EdgeInsets.symmetric(vertical: 14),
// //               ),
// //               child: isBusy && _isSubmitting
// //                   ? Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: const [
// //                         SizedBox(
// //                           height: 22,
// //                           width: 22,
// //                           child: CircularProgressIndicator(
// //                             color: Colors.white,
// //                             strokeWidth: 2,
// //                           ),
// //                         ),
// //                         SizedBox(width: 12),
// //                         Text("Submitting...", style: TextStyle(fontSize: 16)),
// //                       ],
// //                     )
// //                   : const Text("Submit", style: TextStyle(fontSize: 16)),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }



// // // import 'dart:io';
// // // import 'package:attendance_app/utils/location_helper.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:intl/intl.dart';

// // // import 'package:attendance_app/models/upload_entry.dart';
// // // import 'package:attendance_app/database/upload_entry_db.dart';
// // // // import 'package:attendance_app/services/upload_service.dart';

// // // class UploadDetailsScreen extends StatefulWidget {
// // //   final UploadEntry entry;
// // //   final String token;

// // //   const UploadDetailsScreen({
// // //     super.key,
// // //     required this.entry,
// // //     required this.token,
// // //   });

// // //   @override
// // //   State<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
// // // }

// // // class _UploadDetailsScreenState extends State<UploadDetailsScreen> {
// // //   File? _imageFile;
// // //   double? _latitude;
// // //   double? _longitude;
// // //   bool _isSubmitting = false;

// // //   Future<void> _pickImage(ImageSource source) async {
// // //     if (_isSubmitting) return;
// // //     final picker = ImagePicker();
// // //     final picked = await picker.pickImage(source: source);
// // //     if (picked != null) {
// // //       setState(() {
// // //         _imageFile = File(picked.path);
// // //       });
// // //     }
// // //   }

// // //   Future<void> _fetchLocation() async {
// // //     if (_isSubmitting) return;
// // //     final position = await getCurrentPosition();
// // //     if (position != null) {
// // //       setState(() {
// // //         _latitude = position.latitude;
// // //         _longitude = position.longitude;
// // //       });
// // //     } else {
// // //       _showSnackbar("❌ Failed to fetch location");
// // //     }
// // //   }

// // //   Future<void> _submit() async {
// // //     final now = DateTime.now();

// // //     if (now.isAfter(widget.entry.slotEnd)) {
// // //       _showSnackbar("❌ Upload window expired");
// // //       return;
// // //     }

// // //     if (_imageFile == null || _latitude == null || _longitude == null) {
// // //       _showSnackbar("⚠️ Please select image and fetch location");
// // //       return;
// // //     }

// // //     setState(() => _isSubmitting = true);

// // //     try {
// // //       _showSnackbar("⏳ Checking your upload...");

// // //       // final success = await UploadService.uploadEntry(
// // //       //   imageFile: _imageFile!,
// // //       //   latitude: _latitude!,
// // //       //   longitude: _longitude!,
// // //       //   timeSlot: widget.entry.slotLabel,
// // //       //   token: widget.token,
// // //       // );

// // //       // if (!success) {
// // //       //   _showSnackbar("❌ Upload failed. Try again.");
// // //       //   return;
// // //       // }

// // //       // final updatedEntry = widget.entry.copyWith(
// // //       //   imagePath: _imageFile!.path,
// // //       //   latitude: _latitude!,
// // //       //   longitude: _longitude!,
// // //       //   status: 'done',
// // //       //   isSynced: true,
// // //       // );

// // //       // await UploadEntryDB().updateEntry(updatedEntry);

// // //       _showSnackbar("✅ Upload successful");

// // //       Future.delayed(const Duration(seconds: 2), () {
// // //         if (mounted) Navigator.pop(context);
// // //       });
// // //     } catch (e) {
// // //       _showSnackbar("❌ Error: $e");
// // //     } finally {
// // //       if (mounted) setState(() => _isSubmitting = false);
// // //     }
// // //   }

// // //   void _showSnackbar(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message, style: const TextStyle(fontSize: 15)),
// // //         duration: const Duration(seconds: 2),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Upload: ${widget.entry.slotLabel}')),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // //           children: [
// // //             _imageFile != null
// // //                 ? ClipRRect(
// // //                     borderRadius: BorderRadius.circular(8),
// // //                     child: Image.file(
// // //                       _imageFile!,
// // //                       height: 220,
// // //                       fit: BoxFit.cover,
// // //                     ),
// // //                   )
// // //                 : Container(
// // //                     height: 220,
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[200],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     alignment: Alignment.center,
// // //                     child: const Text(
// // //                       "No image selected",
// // //                       style: TextStyle(color: Colors.black54),
// // //                     ),
// // //                   ),

// // //             const SizedBox(height: 16),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // //               children: [
// // //                 ElevatedButton.icon(
// // //                   onPressed: _isSubmitting
// // //                       ? null
// // //                       : () => _pickImage(ImageSource.camera),
// // //                   icon: const Icon(Icons.camera_alt),
// // //                   label: const Text("Camera"),
// // //                 ),
// // //                 ElevatedButton.icon(
// // //                   onPressed: _isSubmitting
// // //                       ? null
// // //                       : () => _pickImage(ImageSource.gallery),
// // //                   icon: const Icon(Icons.photo_library),
// // //                   label: const Text("Gallery"),
// // //                 ),
// // //               ],
// // //             ),

// // //             const SizedBox(height: 16),
// // //             ElevatedButton.icon(
// // //               onPressed: _isSubmitting ? null : _fetchLocation,
// // //               icon: const Icon(Icons.location_on),
// // //               label: const Text("Fetch Location"),
// // //             ),

// // //             if (_latitude != null && _longitude != null)
// // //               Padding(
// // //                 padding: const EdgeInsets.symmetric(vertical: 12),
// // //                 child: Text(
// // //                   "📍 Latitude: $_latitude\n📍 Longitude: $_longitude",
// // //                   textAlign: TextAlign.center,
// // //                   style: const TextStyle(fontSize: 14, color: Colors.black87),
// // //                 ),
// // //               ),

// // //             const Spacer(),

// // //             SizedBox(
// // //               height: 50,
// // //               child: ElevatedButton(
// // //                 onPressed: _isSubmitting ? null : _submit,
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.blue,
// // //                   disabledBackgroundColor: Colors.grey,
// // //                 ),
// // //                 child: _isSubmitting
// // //                     ? Row(
// // //                         mainAxisAlignment: MainAxisAlignment.center,
// // //                         children: const [
// // //                           SizedBox(
// // //                             height: 22,
// // //                             width: 22,
// // //                             child: CircularProgressIndicator(
// // //                               color: Colors.white,
// // //                               strokeWidth: 2,
// // //                             ),
// // //                           ),
// // //                           SizedBox(width: 12),
// // //                           Text("Submitting...", style: TextStyle(fontSize: 16)),
// // //                         ],
// // //                       )
// // //                     : const Text("Submit", style: TextStyle(fontSize: 16)),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // import 'dart:io';
// // // // import 'package:attendance_app/utils/location_helper.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:intl/intl.dart';

// // // // import 'package:attendance_app/models/upload_entry.dart';
// // // // import 'package:attendance_app/database/upload_entry_db.dart';
// // // // // import 'package:attendance_app/services/upload_service.dart';

// // // // class UploadDetailsScreen extends StatefulWidget {
// // // //   final UploadEntry entry;
// // // //   final String token;

// // // //   const UploadDetailsScreen({
// // // //     super.key,
// // // //     required this.entry,
// // // //     required this.token,
// // // //   });

// // // //   @override
// // // //   State<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
// // // // }

// // // // class _UploadDetailsScreenState extends State<UploadDetailsScreen> {
// // // //   File? _imageFile;
// // // //   double? _latitude;
// // // //   double? _longitude;
// // // //   bool _isSubmitting = false;

// // // //   Future<void> _pickImage(ImageSource source) async {
// // // //     final picker = ImagePicker();
// // // //     final picked = await picker.pickImage(source: source);
// // // //     if (picked != null) {
// // // //       setState(() {
// // // //         _imageFile = File(picked.path);
// // // //       });
// // // //     }
// // // //   }

// // // //   Future<void> _fetchLocation() async {
// // // //     final position = await getCurrentPosition();
// // // //     if (position != null) {
// // // //       setState(() {
// // // //         _latitude = position.latitude;
// // // //         _longitude = position.longitude;
// // // //       });
// // // //     } else {
// // // //       _showSnackbar("Failed to fetch location");
// // // //     }
// // // //   }

// // // //   Future<void> _submit() async {
// // // //     final now = DateTime.now();

// // // //     if (now.isAfter(widget.entry.slotEnd)) {
// // // //       _showSnackbar("Upload window expired");
// // // //       return;
// // // //     }

// // // //     if (_imageFile == null || _latitude == null || _longitude == null) {
// // // //       _showSnackbar("Please select image and fetch location");
// // // //       return;
// // // //     }

// // // //     setState(() => _isSubmitting = true);

// // // //     try {
// // // //       // final success = await UploadService.uploadEntry(
// // // //       //   imageFile: _imageFile!,
// // // //       //   latitude: _latitude!,
// // // //       //   longitude: _longitude!,
// // // //       //   timeSlot: widget.entry.slotLabel,
// // // //       //   token: widget.token,
// // // //       // );

// // // //       // if (!success) {
// // // //       //   _showSnackbar("Upload failed. Try again.");
// // // //       //   return;
// // // //       // }

// // // //       // final updatedEntry = widget.entry.copyWith(
// // // //       //   imagePath: _imageFile!.path,
// // // //       //   latitude: _latitude!,
// // // //       //   longitude: _longitude!,
// // // //       //   status: 'done',
// // // //       //   isSynced: true,
// // // //       // );

// // // //       // await UploadEntryDB().updateEntry(updatedEntry);

// // // //       _showSnackbar("✅ Upload successful");

// // // //       // Wait for 2 seconds before navigating back, unless user navigates early
// // // //       Future.delayed(const Duration(seconds: 2), () {
// // // //         if (mounted) {
// // // //           Navigator.pop(context);
// // // //         }
// // // //       });
// // // //     } catch (e) {
// // // //       _showSnackbar("Error: $e");
// // // //     } finally {
// // // //       if (mounted) setState(() => _isSubmitting = false);
// // // //     }
// // // //   }

// // // //   void _showSnackbar(String message) {
// // // //     ScaffoldMessenger.of(
// // // //       context,
// // // //     ).showSnackBar(SnackBar(content: Text(message)));
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final slotRange =
// // // //         "${DateFormat.jm().format(widget.entry.slotStart)} – ${DateFormat.jm().format(widget.entry.slotEnd)}";

// // // //     return Scaffold(
// // // //       appBar: AppBar(title: Text('Upload: ${widget.entry.slotLabel}')),
// // // //       body: Padding(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           children: [
// // // //             Text("Slot Time: $slotRange", style: const TextStyle(fontSize: 16)),

// // // //             const SizedBox(height: 12),
// // // //             _imageFile != null
// // // //                 ? Image.file(_imageFile!, height: 200)
// // // //                 : const Text("No image selected"),

// // // //             const SizedBox(height: 12),
// // // //             ElevatedButton.icon(
// // // //               onPressed: () => _pickImage(ImageSource.camera),
// // // //               icon: const Icon(Icons.camera_alt),
// // // //               label: const Text("Take Photo"),
// // // //             ),
// // // //             ElevatedButton.icon(
// // // //               onPressed: () => _pickImage(ImageSource.gallery),
// // // //               icon: const Icon(Icons.photo),
// // // //               label: const Text("Choose from Gallery"),
// // // //             ),

// // // //             const SizedBox(height: 12),
// // // //             ElevatedButton.icon(
// // // //               onPressed: _fetchLocation,
// // // //               icon: const Icon(Icons.location_on),
// // // //               label: const Text("Fetch Location"),
// // // //             ),

// // // //             if (_latitude != null && _longitude != null)
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(8.0),
// // // //                 child: Text("Lat: $_latitude, Lng: $_longitude"),
// // // //               ),

// // // //             const Spacer(),
// // // //             ElevatedButton(
// // // //               onPressed: _isSubmitting ? null : _submit,
// // // //               child: _isSubmitting
// // // //                   ? const CircularProgressIndicator()
// // // //                   : const Text("Submit"),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
