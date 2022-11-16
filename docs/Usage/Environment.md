> **WARNING** This API is deprecated and will be removed soon. If you need it, please open an issue with your use-case to include in the next release as part of the new original cross-platform API.

## Import package

```dart
import 'package:shared_storage/shared_storage.dart' as shared_storage;
```

Usage sample:

```dart
shared_storage.getRootDirectory(...);
shared_storage.getExternalStoragePublicDirectory(...);
```

But if you import without alias `import '...';` (Not recommeded because can conflict with other method/package names) you should use directly as functions:

```dart
getRootDirectory(...);
getExternalStoragePublicDirectory(...);
```

## Mirror methods

Mirror methods are available to provide an way to call a native method without using any abstraction, available mirror methods:

### <samp>getRootDirectory</samp>

<samp>Mirror of [`Environment.getRootDirectory`](<https://developer.android.com/reference/android/os/Environment#getRootDirectory()>)</samp>

Return **root of the "system"** partition holding the core Android OS. Always present and mounted read-only.

> **Warning** Some new Android versions return null because `SAF` is the new API to handle storage.

```dart
final Directory? rootDir = await getRootDirectory();
```

### <samp>getExternalStoragePublicDirectory</samp>

<samp>Mirror of [`Environment.getExternalStoragePublicDirectory`](<https://developer.android.com/reference/android/os/Environment#getExternalStoragePublicDirectory(java.lang.String)>)</samp>

Get a top-level shared/external storage directory for placing files of a particular type. This is where the user will typically place and manage their own files, **so you should be careful about what you put here to ensure you don't erase their files or get in the way of their own organization.**

> **Warning** Some new Android versions return null because `SAF` is the new API to handle storage.

```dart
final Directory? externalPublicDir = await getExternalStoragePublicDirectory(EnvironmentDirectory.downloads);
```

### <samp>getExternalStorageDirectory</samp>

<samp>Mirror of [`Environment.getExternalStorageDirectory`](<https://developer.android.com/reference/android/os/Environment#getExternalStorageDirectory()>)</samp>

Return the primary shared/external storage directory. This directory may not currently be accessible if it has been mounted by the user on their computer, has been removed from the device, or some other problem has happened.

> **Warning** Some new Android versions return null because `SAF` is the new API to handle storage.

```dart
final Directory? externalDir = await getExternalStorageDirectory();
```

### <samp>getDataDirectory</samp>

<samp>Mirror of [`Environment.getDataDirectory`](<https://developer.android.com/reference/android/os/Environment#getDataDirectory()>)</samp>

Return the user data directory.

> **Info** What may not be obvious is that the "user data directory" returned by `Environment.getDataDirectory` is the system-wide data directory (i.e, typically so far `/data`) and not an application specific directory. Applications of course are not allowed to write to the overall data directory, but only to their particular folder inside it or other select locations whose owner has granted access. [Reference](https://stackoverflow.com/questions/21230629/getfilesdir-vs-environment-getdatadirectory) by [Chris Stratton](https://stackoverflow.com/users/429063/chris-stratton)

> **Warning** Some new Android versions return null because `SAF` is the new API to handle storage.

```dart
final Directory? dataDir = await getDataDirectory();
```

### <samp>getDownloadCacheDirectory</samp>

<samp>Mirror of [`Environment.getDownloadCacheDirectory`](<https://developer.android.com/reference/android/os/Environment#getDownloadCacheDirectory()>)</samp>

Return the download/cache content directory.

Typically the `/data/cache` directory.

> **Warning** Some new Android versions return null because `SAF` is the new API to handle storage.

```dart
final Directory? downloadCacheDir = await getDownloadCacheDirectory();
```

### <samp>getStorageDirectory</samp>

<samp>Mirror of [`Environment.getStorageDirectory`](<https://developer.android.com/reference/android/os/Environment#getStorageDirectory()>)</samp>

Return root directory where all external storage devices will be mounted. For example, `getExternalStorageDirectory()` will appear under this location.

> **Warning** Some new Android versions return null because `SAF` is the new API to handle storage.

```dart
final Directory? storageDir = await getStorageDirectory();
```

## Android Official Documentation

The **Environment** [official documentation is available here.](https://developer.android.com/reference/android/os/Environment)

All the APIs listed in this plugin module are derivated from the official docs.
