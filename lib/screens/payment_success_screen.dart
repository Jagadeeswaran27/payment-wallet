import 'package:flutter/material.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/utils/payment_util.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key, this.amount, this.recipient});

  final double? amount;
  final String? recipient;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _checkController;
  late Animation<double> _circleScale;
  late Animation<double> _checkProgress;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.elasticOut),
    );

    _checkProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _circleController.forward().then((_) {
      _checkController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        goToScreen(context, AppRoutes.home.path);
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _circleController,
                  _checkController,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _circleScale.value,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: _SuccessTickPainter(
                          progress: _checkProgress.value,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Successful',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your payment has been completed successfully',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.amount != null ||
                  (widget.recipient != null &&
                      widget.recipient!.isNotEmpty)) ...[
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (widget.amount != null) ...[
                        _buildDetailRow(
                          'Amount Paid',
                          PaymentUtil.formatAmount(widget.amount!),
                          isAmount: true,
                        ),
                        if (widget.recipient != null &&
                            widget.recipient!.isNotEmpty)
                          const SizedBox(height: 16),
                      ],
                      if (widget.recipient != null &&
                          widget.recipient!.isNotEmpty)
                        _buildDetailRow('Paid to', widget.recipient!),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 3),
              Text(
                'Redirecting to home...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 20 : 16,
            color: AppColors.textPrimary,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SuccessTickPainter extends CustomPainter {
  _SuccessTickPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final circlePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, circlePaint);

    final circleBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, circleBorderPaint);

    final checkPath = _createCheckPath(size);

    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in checkPath.computeMetrics()) {
      final animatedLength = metric.length * progress;
      final extractPath = metric.extractPath(0.0, animatedLength);
      canvas.drawPath(extractPath, checkPaint);
    }
  }

  Path _createCheckPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    final startX = w * 0.22;
    final startY = h * 0.52;
    final midX = w * 0.42;
    final midY = h * 0.68;
    final endX = w * 0.78;
    final endY = h * 0.32;

    path.moveTo(startX, startY);
    path.lineTo(midX, midY);
    path.lineTo(endX, endY);

    return path;
  }

  @override
  bool shouldRepaint(covariant _SuccessTickPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
