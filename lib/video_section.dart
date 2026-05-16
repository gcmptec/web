import 'package:flutter/material.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';
import 'web_video_stub.dart' if (dart.library.html) 'web_video_impl.dart';

class VideoSection extends StatelessWidget {
  const VideoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 80, horizontal: MediaQuery.sizeOf(context).width < 768 ? 24 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SectionLabel('Demo'),
          const SizedBox(height: 12),
          Text(
            'See the Platform in Action',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Early Access Demo — v1',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: GcmpColors.card,
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: buildWebVideo(
                  'assets/assets/videos/demo.mp4',
                  aspectRatio: 16 / 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
