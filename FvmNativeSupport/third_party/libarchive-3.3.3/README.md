# libarchive public headers

These unmodified BSD-licensed headers come from libarchive v3.3.3:

- https://github.com/libarchive/libarchive/tree/v3.3.3/libarchive
- `COPYING` is the upstream license notice.

macOS ships `/usr/lib/libarchive.2.dylib`, but current Xcode SDKs omit its
public headers. Only the headers are vendored here. The macOS extension links
against Apple's system library; no libarchive implementation or Homebrew
dependency is bundled. The API used is available on the macOS 11 deployment
target.
