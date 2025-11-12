import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'theme_page.dart';
import '../services/localization_extension.dart';

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
          content: Text(context.t('send_feedback')),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('success') + ' ❤️'),
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
      appBar: AppBar(title: Text(context.t('feedback'))),
      body: Padding(
        padding: EdgeInsets.all(5.w), // <-- Layout Sizer OK
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('send_feedback'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
                fontSize: 16, // <-- GANTI DARI 13.sp
              ),
            ),
            SizedBox(height: 2.h), // <-- Layout Sizer OK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppTheme.secondaryColor,
                    size: 40, // <-- GANTI DARI 30.sp
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 2.h), // <-- Layout Sizer OK
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.t('send_feedback'),
              ),
              style: TextStyle(fontSize: 15), // <-- GANTI DARI 12.sp
            ),
            SizedBox(height: 3.h), // <-- Layout Sizer OK
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: theme.elevatedButtonTheme.style,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.2.h,
                  ), // <-- Layout Sizer OK
                  child: Text(
                    context.t('send_feedback'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
