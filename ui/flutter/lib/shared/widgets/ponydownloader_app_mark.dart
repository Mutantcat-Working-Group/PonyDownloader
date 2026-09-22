import 'package:flutter/widgets.dart';

import '../theme/app_palette.dart';

/// Brand mark slot rendered from the shipped PonyDownloader app icon.
class PonyDownloaderAppMark extends StatelessWidget {
  const PonyDownloaderAppMark({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'PonyDownloader',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Image.asset(
          'assets/icon/icon.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => ColoredBox(color: AppPalette.of(context).primaryActionBg),
        ),
      ),
    );
  }
}
