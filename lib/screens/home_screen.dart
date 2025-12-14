import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/upload_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xiaoju'),
        centerTitle: true,
      ),
      body: Consumer<UploadProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 上传按钮卡片
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '上传账单文件',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '支持微信账单（XLSX）和支付宝账单（CSV）',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: provider.isUploading
                              ? null
                              : () => _pickAndUploadFile(context, provider),
                          icon: const Icon(Icons.file_upload),
                          label: const Text('选择文件'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 上传状态
                if (provider.isUploading)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text('正在上传，请稍候...'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 上传结果
                if (provider.statusMessage.isNotEmpty && !provider.isUploading)
                  Card(
                    color: provider.lastResult?.success == true
                        ? Colors.green[50]
                        : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                provider.lastResult?.success == true
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: provider.lastResult?.success == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.lastResult?.success == true
                                      ? '上传成功'
                                      : '上传失败',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => provider.clearStatus(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(provider.statusMessage),
                          if (provider.lastResult?.success == true) ...[
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildStatRow('总记录数', provider.lastResult!.total),
                            _buildStatRow('成功导入', provider.lastResult!.imported),
                            _buildStatRow('跳过重复', provider.lastResult!.skipped),
                          ],
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // 上传历史
                if (provider.history.isNotEmpty) ...[
                  Text(
                    '上传历史',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...provider.history.take(5).map((history) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          history.result.success
                              ? Icons.check_circle
                              : Icons.error,
                          color: history.result.success
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(history.fileName),
                        subtitle: Text(
                          '${_formatDateTime(history.timestamp)}\n${history.result.toString()}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAndUploadFile(
    BuildContext context,
    UploadProvider provider,
  ) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name.toLowerCase();

      // 自动识别账单类型
      String billType = 'auto';
      if (fileName.contains('微信') || fileName.contains('wechat')) {
        billType = 'wechat';
      } else if (fileName.contains('支付宝') || fileName.contains('alipay')) {
        billType = 'alipay';
      }

      // 上传文件
      await provider.uploadBill(file, billType);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: $e')),
        );
      }
    }
  }
}