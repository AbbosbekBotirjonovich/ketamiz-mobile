import 'package:image_picker/image_picker.dart';

/// Centralized image picking with on-device compression applied *before*
/// the image is loaded into memory or sent to the backend.
///
/// `image_picker` downsamples/re-encodes natively (also on web), so this
/// caps both memory usage and upload size regardless of the source photo's
/// resolution. Tune the defaults here to change it everywhere at once.
class ImageHelper {
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  // Keep documents (licence, passport, tech passport) readable while still
  // shrinking a typical 12MP phone photo (~3–5 MB) down to a few hundred KB.
  static const double _maxDimension = 1600;
  static const int _quality = 70;

  static Future<XFile?> pick(
    ImageSource source, {
    double maxDimension = _maxDimension,
    int quality = _quality,
  }) {
    return _picker.pickImage(
      source: source,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: quality,
    );
  }
}
