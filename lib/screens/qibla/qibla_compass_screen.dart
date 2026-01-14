import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'بوصلة القبلة',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _deviceSupport,
        builder: (_, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ: ${snapshot.error}',
                style: const TextStyle(color: AppColors.white),
              ),
            );
          }

          if (snapshot.data == true) {
            return FutureBuilder(
              future: _checkLocationStatus(),
              builder: (_, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  );
                }

                if (snapshot.hasData && snapshot.data!) {
                  return _buildQiblahCompass();
                } else {
                  return _buildPermissionRequest();
                }
              },
            );
          } else {
            return _buildDeviceNotSupported();
          }
        },
      ),
    );
  }

  Future<bool> _checkLocationStatus() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      final newPermission = await Geolocator.requestPermission();
      return newPermission == LocationPermission.whileInUse ||
          newPermission == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Widget _buildDeviceNotSupported() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.greyText,
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'جهازك لا يدعم حساس البوصلة',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.explore_off,
            size: 80,
            color: AppColors.greyText,
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'يتطلب الوصول إلى الموقع والبوصلة',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await Geolocator.requestPermission();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'منح الأذونات',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblahCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطأ: ${snapshot.error}',
              style: const TextStyle(color: AppColors.white),
            ),
          );
        }

        final qiblahDirection = snapshot.data!;
        return _buildCompass(qiblahDirection);
      },
    );
  }

  Widget _buildCompass(QiblahDirection qiblahDirection) {
    final compassRotation = (qiblahDirection.direction * (math.pi / 180) * -1);
    final qiblaAngle = (qiblahDirection.qiblah * (math.pi / 180) * -1);

    // Check if aligned with Qibla (offset is the angle difference from Qibla)
    // final isAligned = qiblahDirection.offset.abs() <= 10;
    final isAligned = qiblahDirection.offset.abs() <= 10 ||
        (qiblahDirection.direction - qiblahDirection.qiblah).abs() <= 10;

    // Debug
    print('Offset: ${qiblahDirection.offset}, IsAligned: $isAligned');

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Qibla indicator at top
            Transform.rotate(
              angle: qiblaAngle,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.mosque,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Compass
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass dial
                  Transform.rotate(
                    angle: compassRotation,
                    child: CustomPaint(
                      size: const Size(320, 320),
                      painter: CompassPainter(),
                    ),
                  ),
                  // Kaaba icon in center
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.mosque,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  // Qibla direction arrow
                  Transform.rotate(
                    angle: qiblaAngle,
                    child: CustomPaint(
                      size: const Size(320, 320),
                      painter: ArrowPainter(isAligned: isAligned),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Qibla angle info
            Text(
              'اتجاه القبلة: ${qiblahDirection.qiblah.toStringAsFixed(1)}°',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'تنبية : ربما تحتاج لتحريك الهاتف في حركة دائرية لإعادة ضبط البوصلة',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Compass painter
class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw direction markers
    final directions = [
      {'angle': 0.0, 'label': 'N'},
      {'angle': math.pi / 4, 'label': 'NE'},
      {'angle': math.pi / 2, 'label': 'E'},
      {'angle': 3 * math.pi / 4, 'label': 'SE'},
      {'angle': math.pi, 'label': 'S'},
      {'angle': 5 * math.pi / 4, 'label': 'SW'},
      {'angle': 3 * math.pi / 2, 'label': 'W'},
      {'angle': 7 * math.pi / 4, 'label': 'NW'},
    ];

    for (final dir in directions) {
      final angle = dir['angle'] as double;
      final label = dir['label'] as String;

      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);

      final dashPaint = Paint()
        ..color = Colors.white
        ..strokeWidth =
            label == 'N' || label == 'S' || label == 'E' || label == 'W' ? 4 : 3
        ..style = PaintingStyle.stroke;

      final dashLength =
          label == 'N' || label == 'S' || label == 'E' || label == 'W'
              ? 20.0
              : 12.0;
      final dashStart = Offset(
        center.dx + (radius - dashLength - 5) * math.cos(angle - math.pi / 2),
        center.dy + (radius - dashLength - 5) * math.sin(angle - math.pi / 2),
      );
      final dashEnd = Offset(x, y);

      canvas.drawLine(dashStart, dashEnd, dashPaint);

      if (label == 'N' || label == 'S' || label == 'E' || label == 'W') {
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - textPainter.width / 2,
            y - textPainter.height / 2,
          ),
        );
      }
    }

    // Draw small dots around the compass
    for (int i = 0; i < 33; i++) {
      final angle = (i * 2 * math.pi / 33) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final dotPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}

// Arrow painter pointing to Qibla
class ArrowPainter extends CustomPainter {
  final bool isAligned;

  ArrowPainter({this.isAligned = false});

  @override
  void paint(Canvas canvas, Size size) {
    // اختيار اللون بناءً على الحالة
    final paint = Paint()
      ..color = isAligned ? AppColors.primaryGreen : Colors.red
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    // رسم السهم
    path.moveTo(center.dx, center.dy - 120);
    path.lineTo(center.dx - 15, center.dy - 90);
    path.lineTo(center.dx - 5, center.dy - 90);
    path.lineTo(center.dx - 5, center.dy - 60);
    path.lineTo(center.dx + 5, center.dy - 60);
    path.lineTo(center.dx + 5, center.dy - 90);
    path.lineTo(center.dx + 15, center.dy - 90);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
