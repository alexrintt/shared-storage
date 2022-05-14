> If you already have Flutter configured you can skip this step

## Setting up your local environment

All you need is to make sure you can run Flutter apps in your machine from your shell, by `flutter run` inside your Flutter project as well you can also run your Flutter project inside Android Studio IDE. Since this IDE support Android process debugging.

### Configuring Flutter

You should configure your Flutter local environment properly. There's several online resources can help you do that as well the official documentation:

- [Flutter Official documentation](https://docs.flutter.dev/get-started/install)
- [How to Install and Set Up Flutter on Ubuntu 16.04+](https://www.freecodecamp.org/news/how-to-install-and-setup-flutter-on-ubuntu/)
- [Flutter – Installation on macOS](https://www.geeksforgeeks.org/flutter-installation-on-macos/)
- [How to Install Flutter on Windows?](https://www.geeksforgeeks.org/how-to-install-flutter-on-windows/)

In summary: all you need to do is to setup Android plus the Flutter binaries available globally through your CLI interface.

To ensure everything is working, type `flutter doctor` in your shell, you should see something like this:

```md
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 2.10.0, on Microsoft Windows [Version 10.0.19043.1645], locale en-US)
[√] Android toolchain - develop for Android devices (Android SDK version 31.0.0)
[√] Chrome - develop for the web
[√] Visual Studio - develop for Windows (Visual Studio Build Tools 2019 16.11.13)
[√] Android Studio (version 2020.3)
[√] IntelliJ IDEA Community Edition (version 2021.3)
[√] Connected device (2 available)
! Device RX8M40FQ3KF is offline.
[√] HTTP Host Availability

• No issues found!
```
