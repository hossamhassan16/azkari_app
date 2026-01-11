import 'package:azkari_app/models/allah_names_model.dart';
import 'package:azkari_app/services/allah_names_services.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  final AllahNamesService _service = AllahNamesService();
  List<AllahNameModel> _names = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    try {
      final names = await _service.loadNames();
      if (!mounted) return;
      setState(() {
        _names = names;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'أسماء الله الحسنى',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkBackground,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ في تحميل البيانات',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadNames,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _names.length,
                  itemBuilder: (context, index) {
                    final name = _names[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${name.id}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          name.nameAr,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            name.meaningAr,
                            style: const TextStyle(
                              color: AppColors.greyText,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
