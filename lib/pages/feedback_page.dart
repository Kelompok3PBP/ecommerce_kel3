import 'package:flutter/material.dart'; // <--- PASTIKAN INI ADA
import 'package:sizer/sizer.dart';
import 'theme_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  void _submitFeedback() {
    if (_rating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Berikan rating dan komentar terlebih dahulu'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback terkirim! Terima kasih ❤️'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _rating = 0;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Aplikasi'),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bantu kami menjadi lebih baik dengan feedback kamu',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppTheme.secondaryColor,
                    size: 30.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tulis komentar kamu',
              ),
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 3.h),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: theme.elevatedButtonTheme.style,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
                  child: Text(
                    'Kirim Feedback',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}