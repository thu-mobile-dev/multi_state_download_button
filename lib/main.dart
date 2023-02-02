import 'package:flutter/material.dart';

import 'package:multi_state_download_button/controller.dart';
import 'package:multi_state_download_button/extension.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: MultiStateDownloadButton())),
      debugShowCheckedModeBanner: false,
    ),
  );
}

@immutable
class MultiStateDownloadButton extends StatefulWidget {
  const MultiStateDownloadButton({super.key});

  @override
  State<MultiStateDownloadButton> createState() =>
      _MultiStateDownloadButtonState();
}

class _MultiStateDownloadButtonState extends State<MultiStateDownloadButton> {
  final DownloadController _downloadController = SimulatedDownloadController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenSize.shorterSide(context, percentage: 1 / 2),
      child: AnimatedBuilder(
        animation: _downloadController,
        builder: (context, child) {
          return DownloadButton(
            status: _downloadController.downloadStatus,
            downloadProgress: _downloadController.progress,
            onDownload: _downloadController.startDownload,
            onCancel: _downloadController.stopDownload,
            onOpen: _downloadController.openDownload,
          );
        },
      ),
    );
  }
}

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0.0,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  final DownloadStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Duration transitionDuration;

  bool get _isDownloading => status == DownloadStatus.downloading;

  bool get _isFetching => status == DownloadStatus.fetchingDownload;

  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded:
        onDownload();
        break;
      case DownloadStatus.fetchingDownload:
        // do nothing.
        break;
      case DownloadStatus.downloading:
        onCancel();
        break;
      case DownloadStatus.downloaded:
        onOpen();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: [
          ButtonShapeWidget(
            transitionDuration: transitionDuration,
            isDownloaded: _isDownloaded,
            isDownloading: _isDownloading,
            isFetching: _isFetching,
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: transitionDuration,
              opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
              curve: Curves.ease,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ProgressIndicatorWidget(
                    downloadProgress: downloadProgress,
                    isDownloading: _isDownloading,
                    isFetching: _isFetching,
                  ),
                  if (_isDownloading)
                    Icon(
                      Icons.stop,
                      size: ScreenSize.shorterSide(context,
                          percentage: 1 / 2 * 1 / 4),
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
  });

  final bool isDownloading;
  final bool isDownloaded;
  final bool isFetching;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    var shape = ShapeDecoration(
      shape: const StadiumBorder(),
      color: Colors.grey[200],
    );

    if (isDownloading || isFetching) {
      shape = const ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.white,
      );
    }

    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration: shape,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical:
                ScreenSize.shorterSide(context, percentage: 1 / 2 * 1 / 12)),
        child: AnimatedOpacity(
          duration: transitionDuration,
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          curve: Curves.ease,
          child: Text(
            isDownloaded ? 'OPEN' : 'GET',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize:
                    ScreenSize.shorterSide(context, percentage: 1 / 2 * 1 / 6)),
          ),
        ),
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor: isDownloading ? Colors.grey[200] : Colors.white,
            valueColor: AlwaysStoppedAnimation(
                isFetching ? Colors.grey[200] : Colors.blue),
            strokeWidth:
                ScreenSize.shorterSide(context, percentage: 1 / 2 * 1 / 36),
            value: isFetching ? null : progress,
          );
        },
      ),
    );
  }
}
