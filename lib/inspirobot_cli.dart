import 'dart:async';
import 'dart:io';

import 'package:batcher/batcher.dart';
import 'package:inspirobot/inspirobot.dart';
import 'package:path/path.dart';

/// Downloads [count] images to the [outputDirectory], using [threads]
/// simultaneous I/O operations.
///
/// Emits a [Uri] when the image is downloaded.
Stream<Uri> download({
  required int count,
  required int threads,
  required bool christmas,
  required Directory outputDirectory,
}) {
  final inspiroBot = InspiroBot();
  final client = HttpClient();

  return List.generate(
    count,
    (_) => () async {
      final imageUrl = await inspiroBot.generate(christmas: christmas);
      final outputFile =
          File(join(outputDirectory.path, imageUrl.pathSegments.last));
      final outputSink = outputFile.openWrite();
      final downloadFuture =
          (await (await client.getUrl(imageUrl)).close()).pipe(outputSink);
      await downloadFuture;
      return imageUrl;
    },
    growable: false,
  ).streamBatch(threads)
    ..drain().then((_) {
      client.close();
      inspiroBot.close();
    });
}
