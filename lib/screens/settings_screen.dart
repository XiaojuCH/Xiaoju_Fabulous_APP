import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/upload_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isLoading = true;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('api_key') ?? '';
    final budget = prefs.getDouble('monthly_budget') ?? 0.0;
    _apiKeyController.text = apiKey;
    _budgetController.text = budget > 0 ? budget.toStringAsFixed(0) : '';
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      _showMessage('请输入 API 密钥', isError: true);
      return;
    }

    if (apiKey.length != 64) {
      _showMessage('API 密钥长度应为 64 位', isError: true);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_key', apiKey);

      // 更新 Provider 中的 API 密钥
      if (mounted) {
        context.read<UploadProvider>().updateApiKey(apiKey);
      }

      _showMessage('API 密钥保存成功');
    } catch (e) {
      _showMessage('保存失败: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _saveBudget() async {
    final budgetText = _budgetController.text.trim();

    if (budgetText.isEmpty) {
      _showMessage('请输入预算金额', isError: true);
      return;
    }

    final budget = double.tryParse(budgetText);
    if (budget == null || budget < 0) {
      _showMessage('请输入有效的金额', isError: true);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_budget', budget);
      _showMessage('预算保存成功');
    } catch (e) {
      _showMessage('保存失败: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // API 密钥设置
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.key,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'API 密钥',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _apiKeyController,
                          obscureText: _obscureApiKey,
                          decoration: InputDecoration(
                            labelText: 'API 密钥',
                            hintText: '请输入 64 位 API 密钥',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureApiKey
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureApiKey = !_obscureApiKey;
                                });
                              },
                            ),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '从网站获取：消费记录 → API 密钥管理 → 生成新密钥',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _saveApiKey,
                          icon: const Icon(Icons.save),
                          label: const Text('保存'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 每月预算设置
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '每月预算',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '预算金额（元）',
                            hintText: '请输入每月预算',
                            border: OutlineInputBorder(),
                            prefixText: '¥ ',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '设置每月预算后，结余将基于预算计算',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _saveBudget,
                          icon: const Icon(Icons.save),
                          label: const Text('保存'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 关于
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('关于'),
                        subtitle: const Text('Xiaoju v1.0.4'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.web),
                        title: const Text('网站'),
                        subtitle: const Text('https://www.xiaojuch.com'),
                        onTap: () {
                          // TODO: 打开网站
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text('使用说明'),
                        onTap: () {
                          _showHelpDialog();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 权限说明
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '权限说明',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionItem(
                          Icons.folder_open,
                          '存储权限',
                          '读取 Download 文件夹中的账单文件',
                        ),
                        _buildPermissionItem(
                          Icons.cloud_upload,
                          '网络权限',
                          '上传文件到服务器',
                        ),
                        _buildPermissionItem(
                          Icons.notifications,
                          '通知权限',
                          '显示上传结果通知',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. 获取 API 密钥',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('登录 xiaojuch.com 网站 → 消费记录 → API 密钥管理 → 生成新密钥'),
              SizedBox(height: 16),
              Text(
                '2. 设置 API 密钥',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('在设置页面输入并保存 API 密钥'),
              SizedBox(height: 16),
              Text(
                '3. 上传账单',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('在首页点击"选择文件"，选择微信或支付宝账单文件'),
              SizedBox(height: 16),
              Text(
                '4. 查看结果',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('上传完成后会显示导入统计，可在网站查看详细数据'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
