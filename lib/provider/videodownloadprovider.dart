import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';

class VideoDownloadProvider extends ChangeNotifier {
  final Map<int, int> _downloadProgress = {};
  final Map<int, double> encryptProgress = {};

  int? currentItemId;
  bool loading = false;
  // inside VideoDownloadProvider
  double _convertProgress = 0.0;
  bool _isConverting = false;

  double get convertProgress => _convertProgress;
  bool get isConverting => _isConverting;

  void setConvertProgress(double progress) {
    _convertProgress = progress;
    notifyListeners();
  }

  void setConverting(bool value) {
    _isConverting = value;
    notifyListeners();
  }

  int getProgress(int itemId) => _downloadProgress[itemId] ?? 0;
  double getEncryptProgress(int itemId) => encryptProgress[itemId] ?? 0.0;

  void setDownloadProgress(int itemId, int progress) {
    _downloadProgress[itemId] = progress.clamp(0, 100);
    currentItemId = itemId;
    loading = (progress != -1);
    notifyListeners();
    printLog('Download progress: $progress% for itemId: $itemId');
  }

  void setEncryptProgress(int itemId, double progress) {
    encryptProgress[itemId] = progress.clamp(0.0, 1.0);
    notifyListeners();
    printLog('Encrypt progress: $progress for itemId: $itemId');
  }

  void setCurrentDownload(int? itemId) {
    currentItemId = itemId;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void clearItem(int itemId) {
    _downloadProgress.remove(itemId);
    encryptProgress.remove(itemId);
    notifyListeners();
  }

  void clearAll() {
    _downloadProgress.clear();
    encryptProgress.clear();
    currentItemId = null;
    loading = false;
    notifyListeners();
  }
}
