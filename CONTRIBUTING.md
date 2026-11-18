# Contributing

Open an issue for reproducible bugs and submit changes on a branch. Run `swift test` and `./Scripts/build-app.sh` on macOS before opening a pull request. Include the test results and keep changes focused on the reported behavior.

Keep USB matching scoped to supported interfaces. For protocol changes, cite the reference or hardware observation that supports the change and add a report-level test when it can catch regressions.

## Hardware check

Use a K70 RGB MK.2 Low Profile RAPIDFIRE with USB ID `1B1C:1B55` and a Mac running macOS 14 or later. Record the macOS version, Mac chip, and firmware version if available.

1. Open the app with the board disconnected. Check that the preview and profiles work, and Apply is disabled.
2. Connect the keyboard. Apply solid red, green, and blue in turn. Confirm typing and media controls continue to work.
3. Set the base color to blue. Paint `Ç`, the main Enter key, and the extra `/` key beside right Shift different colors. Apply and confirm the three physical keys match the preview.
4. Try brightness at 0%, 50%, and 100%, both animations, and **Off**. Confirm animation stops when another effect is applied.
5. Save a named profile, quit normally, then reopen the app and load it. Check that its colors, overrides, brightness, and effect settings return.
6. Restore onboard lighting during an animation, then apply again and quit. Confirm onboard lighting returns both times.
7. Unplug during an animation. Verify the disconnected state and replug. Confirm that a fresh Apply works, then repeat after waking the Mac from sleep.
