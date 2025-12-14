import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class UploadProvider extends ChangeNotifier {
  final ApiService _apiService;

  bool _isUploading = false;
  String _statusMessage = '';
  UploadResult? _lastResult;
  List<UploadHistory> _history = [];

  UploadProvider(this._apiService);

  bool get isUploading => _isUploading;
  String get statusMessage => _statusMessage;
  UploadResult? get lastResult => _lastResult;
  List<UploadHistory> get history => _history;

  /// 上传账单文件
  Future<void> uploadBill(File file, String billType) async {
    _isUploading = true;
    _statusMessage = '正在上传...';
    notifyListeners();

    try {
      final result = await _apiService.uploadBill(file, billType);
      _lastResult = result;

      // 添加到历史记录
      _history.insert(0, UploadHistory(
        fileName: file.path.split('/').last,
        billType: billType,
        result: result,
        timestamp: DateTime.now(),
      ));

      if (result.success) {
        _statusMessage = '上传成功！${result.toString()}';
      } else {
        _statusMessage = '上传失败：${result.message}';
      }
    } catch (e) {
      _statusMessage = '上传出错：$e';
      _lastResult = null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// 清空状态
  void clearStatus() {
    _statusMessage = '';
    _lastResult = null;
    notifyListeners();
  }

  /// 更新 API 密钥
  void updateApiKey(String apiKey) {
    _apiService.updateApiKey(apiKey);
  }
}

class UploadHistory {
  final String fileName;
  final String billType;
  final UploadResult result;
  final DateTime timestamp;

  UploadHistory({
    required this.fileName,
    required this.billType,
    required this.result,
    required this.timestamp,
  });
}