import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/review_provider.dart';
import 'widgets/review_card.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  final String placeId;

  const AddReviewScreen({super.key, required this.placeId});

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final _textController = TextEditingController();
  double _rating = 0;
  final List<String> _imageUrls = []; // In production, use uploaded URLs
  final List<XFile> _pickedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _rating > 0 && _textController.text.trim().length >= 10;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (file != null) {
      setState(() => _pickedImages.add(file));

      try {
        final url = await _uploadImage(file);
        setState(() => _imageUrls.add(url));
      } catch (e) {
        // Remove the image from picked images if upload failed
        setState(() => _pickedImages.remove(file));
        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<String> _uploadImage(XFile file) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child(
        'reviews/${widget.placeId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );

      final uploadTask = imageRef.putData(
        await file.readAsBytes(),
        SettableMetadata(contentType: 'image/${file.name.split('.').last}'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Handle upload error - could show a snackbar or dialog
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Images are already uploaded when picked, so no need for additional delay

    ref
        .read(reviewProvider(widget.placeId).notifier)
        .addReview(
          userId: user.id,
          userName: user.name,
          userAvatar: user.avatarUrl,
          rating: _rating,
          text: _textController.text.trim(),
          images: _imageUrls,
        );

    ref.read(authProvider.notifier).incrementReviewCount();

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessAndPop();
    }
  }

  void _showSuccessAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ZuriColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Review Posted!',
                style: ZuriTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for helping the ZURI community!',
                style: ZuriTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close review screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZuriColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZuriColors.background,
      appBar: AppBar(
        backgroundColor: ZuriColors.surface,
        title: const Text('Write a Review'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded, color: ZuriColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: (_canSubmit && !_isSubmitting) ? _submit : null,
            child: Text(
              'Post',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _canSubmit
                    ? ZuriColors.primary
                    : ZuriColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Star Rating ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ZuriColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: ZuriColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'How was your experience?',
                    style: ZuriTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _ratingLabel(_rating),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _rating > 0
                          ? ZuriColors.primary
                          : ZuriColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StarRatingSelector(
                    rating: _rating,
                    onRatingChanged: (r) => setState(() => _rating = r),
                    size: 44,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Review text ───────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: ZuriColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: ZuriColors.cardShadow,
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: ZuriTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText:
                      'Share your experience — what did you love? What could be better?',
                  hintStyle: ZuriTextStyles.bodyLarge.copyWith(
                    color: ZuriColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: ZuriColors.surface,
                  contentPadding: const EdgeInsets.all(18),
                  counterStyle: ZuriTextStyles.labelSmall,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Photo upload (Pro feature) ─────────────────────────
            const Text('Add Photos', style: ZuriTextStyles.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Add up to 5 photos of this place',
              style: ZuriTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add photo button
                  if (_pickedImages.length < 5)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: ZuriColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ZuriColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: ZuriColors.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: ZuriTextStyles.labelSmall.copyWith(
                                color: ZuriColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Picked images preview
                  ..._pickedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final hasUrl = index < _imageUrls.length;

                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: ZuriColors.shimmerBase,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: hasUrl
                                ? Image.network(
                                    _imageUrls[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.image,
                                      color: ZuriColors.textTertiary,
                                      size: 40,
                                    ),
                                  )
                                : const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 14,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedImages.removeAt(index);
                                if (index < _imageUrls.length) {
                                  _imageUrls.removeAt(index);
                                }
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_canSubmit && !_isSubmitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZuriColors.primary,
                  disabledBackgroundColor: ZuriColors.border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post Review',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(double r) {
    switch (r.toInt()) {
      case 1:
        return 'Terrible 😞';
      case 2:
        return 'Poor 😕';
      case 3:
        return 'Okay 🙂';
      case 4:
        return 'Good 😊';
      case 5:
        return 'Excellent! 🤩';
      default:
        return 'Tap to rate';
    }
  }
}
