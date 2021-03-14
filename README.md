# InspiroBot CLI
A tool to download images from [InspiroBot].

## About
InspiroBot CLI can download images from [InspiroBot], using multiple
connections at once to reduce latency.

It is written in Dart, using [`package:inspirobot`](https://pub.dev/packages/inspirobot).

## Usage
```
Usage: inspirobot_cli <output directory> [arguments]

-h, --help                      Show usage information.
-v, --version                   Show version information.
-c, --count=<IMAGE_COUNT>       The number of images to download.
                                (defaults to "1")
-j, --threads=<THREAD_COUNT>    The number of download threads to use.
                                (defaults to "32")
    --christmas                 Download christmas-related images.
```

## Building
InspiroBot CLI is written in Dart. The [Dart SDK](https://dart.dev/get-dart) is
required for compilation.

```shell
$ dart pub get
$ dart compile exe bin/inspirobot_cli.dart -o <output file>
```

[InspiroBot]: https://inspirobot.me