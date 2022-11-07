## Warning

This labeling will be removed soon, I it will be replaced with a full original API as described in [#56](https://github.com/alexrintt/shared-storage/issues/56).

## Labeling

When refering to the docs you'll usually see some labels before the method/class names.

They are label which identifies where the API came from.

This package is intended to be a mirror of native Android APIs. Which means all methods and classes are just a re-implementation of native APIs, but some places we can't do that due technical reasons. So we put a label to identify when it'll happen.

You are fully encouraged to understand/learn the native Android APIs to use this package. All packages (not only this one) are derivated from native APIs depending on the platform (Windows, iOS, Android, Unix, Web, etc.), to have a understing about it can help not only here but on all your Flutter journey, and even in other frameworks.

| **Label**     | Description                                                                                                                                  |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Internal**  | New internal type (class). Usually they are only to keep a safe typing and are not usually intended to be instantiated for the package user. |
| **Original**  | Original API which only exists inside this package and doesn't mirror any Android API (an abstraction).                                      |
| **Mirror**    | Pure mirror API (method/class) which was re-implemented in Dart from a native original API.                                                  |
| **Alias**     | Convenient methods. They do not implement anything new but create a new abstraction from an existing API.                                    |
| **External**  | API from third-part Android libraries.                                                                                                       |
| **Extension** | These are most alias methods implemented through Dart extensions.                                                                            |
