import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final ValueNotifier<double> _ratingNotifier = ValueNotifier(0);
  final TextEditingController _commentController = TextEditingController();

  void _submitFeedback() {
    if (_ratingNotifier.value == 0 || _commentController.text.trim().isEmpty) {
      NotificationService.showIfEnabledDialog(
        context,
        title: 'Validasi',
        body: context.t('send_feedback'),
      );
      return;
    }
    NotificationService.showIfEnabledDialog(
      context,
      title: context.t('success'),
      body: 'Terima kasih atas feedback Anda! ❤️',
    );
    _ratingNotifier.value = 0;
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('feedback')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('send_feedback'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 2.h),
              ValueListenableBuilder<double>(
                valueListenable: _ratingNotifier,
                builder: (context, rating, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: AppTheme.secondaryColor,
                          size: 40,
                        ),
                        onPressed: () {
                          _ratingNotifier.value = index + 1.0;
                        },
                      );
                    }),
                  );
                },
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.t('send_feedback'),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(fontSize: 15),
              ),
              SizedBox(height: 3.h),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: theme.elevatedButtonTheme.style,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      child: Text(
                        context.t('send_feedback'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  @override
  void dispose() {
    _ratingNotifier.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
