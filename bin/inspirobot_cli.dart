import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:inspirobot_cli/app_info.dart';
import 'package:inspirobot_cli/inspirobot_cli.dart';
import 'package:progressbar2/progressbar2.dart';

Future<void> main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show usage information.',
      negatable: false,
    )
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Show version information.',
      negatable: false,
    )
    ..addOption(
      'count',
      abbr: 'c',
      help: 'The number of images to download.',
      valueHelp: 'IMAGE_COUNT',
      defaultsTo: '1',
    )
    ..addOption(
      'threads',
      abbr: 'j',
      help: 'The number of download threads to use.',
      valueHelp: 'THREAD_COUNT',
      defaultsTo: '32',
    )
    ..addFlag(
      'christmas',
      help: 'Download christmas-related images.',
      negatable: false,
    );

  final ArgResults parsedArguments;
  try {
    parsedArguments = argParser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exit(2);
  }

  if (parsedArguments['help'] == true) {
    stdout
      ..writeln(versionInfo)
      ..writeln()
      ..writeln(
          'Usage: ${Platform.script.pathSegments.last} <output directory> [arguments]')
      ..writeln()
      ..writeln(argParser.usage);
    exit(0);
  }

  if (parsedArguments['version'] == true) {
    stdout.writeln(versionInfo);
    exit(0);
  }

  final count = parseIntArgument('count', parsedArguments, 1);
  final threads = parseIntArgument('threads', parsedArguments, 1);
  final christmas = parsedArguments['christmas'] as bool;

  if (parsedArguments.rest.length != 1) {
    stderr.writeln('Please provide an output directory!');
    exit(2);
  }
  final outputDirectory = Directory(parsedArguments.rest[0]);
  if (!await outputDirectory.parent.exists()) {
    stderr.writeln(
        'Parent of output directory "${outputDirectory.path}" does not exist!');
    exit(-1);
  }
  await outputDirectory.create();

  final progressBar = ProgressBar(
    formatter: (current, total, progress, elapsed) =>
        '$current/$total (${(progress * 100).round()}%) [${ProgressBar.formatterBarToken}] ${elapsed.inSeconds}s',
    total: count,
    width: max(count, 10),
  );

  if (stdout.hasTerminal) progressBar.render();
  await for (final _ in download(
    count: count,
    threads: threads,
    christmas: christmas,
    outputDirectory: outputDirectory,
  )) {
    ++progressBar.value;
    if (stdout.hasTerminal) progressBar.render();
  }
}

int parseIntArgument(
  String argument,
  ArgResults parsedArguments, [
  int? minimum,
]) {
  final result = int.tryParse(parsedArguments[argument] as String);
  if (result == null || (minimum != null && result < minimum)) {
    stderr.writeln('Invalid value for argument "$argument"!');
    exit(2);
  }
  return result;
}
