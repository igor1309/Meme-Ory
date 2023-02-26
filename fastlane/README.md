fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```



### ios release

```sh
[bundle exec] fastlane ios release
```



### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Create AppStore Previews

### ios bootstrap_code_signing

```sh
[bundle exec] fastlane ios bootstrap_code_signing
```

Re-obtain match code-signing credentials for Development, AdHoc, and AppStore

### ios distribute_to_appstore

```sh
[bundle exec] fastlane ios distribute_to_appstore
```

Build for AppStore submission and send to TestFlight

### ios build_appstore

```sh
[bundle exec] fastlane ios build_appstore
```

Build for AppStore submission

### ios sync_device_info

```sh
[bundle exec] fastlane ios sync_device_info
```

Update Devices UUID's on the Developer Portal

### ios ping_slack

```sh
[bundle exec] fastlane ios ping_slack
```



### ios pilot_to_slack

```sh
[bundle exec] fastlane ios pilot_to_slack
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
