# ALVR wired sleep/wake reconnect patch

Applies to upstream `e8ca92b15d7c93765f828ca245f26de678c7f154`, the source
used by `21.0.0-dev14+nightly.2026.11.06` and `.2026.11.07`.
Related upstream report: https://github.com/alvr-org/ALVR/issues/3190.

## Changes

- Treat TCP EOF during a prefix or payload as a closed connection, not a retry.
- Preserve fragmented prefixes across retries without repeatedly peeking the same bytes.
- Keep independent shutdown handles for control and TCP streaming sockets. Shut down
  both directions before taking sender locks and joining streaming workers.
- Release the server session write lock before taking sender locks. A video producer
  can hold its sender lock while reading the session, so the old order can deadlock.
- On the client, expose the Disconnecting state to workers before waiting for sender
  locks. Apply the same I/O cancellation to the client teardown path.
- Keep the normal transition to Disconnected **after** workers have exited. There is
  no timer that forcibly resets the state and leaves old workers running.

UDP data transport is unchanged; its control TCP socket is cancelled during teardown.
The wire protocol and settings schema are unchanged.

## Validation

In a checkout of the base commit with the patch applied:

```sh
git apply --check /path/to/alvr-wired-reconnect.patch # before applying
git apply /path/to/alvr-wired-reconnect.patch
cargo test -p alvr_sockets --lib
cargo check -p alvr_server_core -p alvr_client_core
```

The patch adds nine loopback TCP tests: EOF before/during prefixes and during payloads
on both control and stream sockets; fragmented stream packets across retries; and
cancellation of blocked receives and sends. Tests use bounded channel waits so an
EOF loop regression fails instead of hanging the test runner indefinitely.

Local results: nine socket tests passed; server/client core checks passed on Linux.
This is not an Android cross-build or a headset sleep/wake end-to-end test.

## Deployment and device verification

`modules/gaming/default.nix` applies this patch alongside the existing local packaging
and encoder fixes. Building the package alone does not activate it or restart SteamVR.

The Android client also needs rebuilding from this patched source for the complete
fix. An unchanged official nightly APK still contains the old client TCP reader and
teardown path. Preserve the existing signing key; do not uninstall the client or clear
its data just to bypass an APK signature mismatch.

After both sides are updated, reconnect and repeat headset removal/sleep/wake several
times. Confirm automatic return to Streaming, no persistent Disconnecting state, no
accumulating CLOSE-WAIT sockets on ports 9943/9944, and no growing worker/thread count.
Also test a USB unplug/replug and a normal SteamVR exit. Do not use the state-reset
API workaround during these tests, since it would hide incomplete teardown.

The separate NVIDIA device-lost/SteamVR desktop-capture crashes are not addressed here.
