# Change Log
All notable changes to this project will be documented in this file.

---

## Master

#### Updated

* Rename `RxProgress.totalBytesWritten` to `RxProgress.bytesRemaining`.
* Rename `RxProgress.totalBytesExpectedToWrite` to `RxProgress.totalBytes`.
* Convert `RxProgress.bytesRemaining` from a stored- to a computed-property.
* Convert `RxProgress.floatValue` from a function to a computed-property.
* Add `Equatable` conformation to `RxProgress`.

#### Fixed

* Fix `Reactive<DataRequest>.progress` logic so it actually completes.
