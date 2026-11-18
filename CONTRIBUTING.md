# Contributing to K70 Studio

Use a branch for each bug fix or feature. Keep pull requests focused and
describe the behavior change and how you verified it. Link a related issue
in the pull request if there is one.

## Commits

Use a short, imperative subject with a Conventional Commits prefix.
Keep each commit focused on one change. Add a body after a blank line when
the reasoning or compatibility impact needs more detail.
[Conventional Commits specification][commits]

```text
feat: add a breathing lighting effect
fix: restore onboard lighting after an interrupted animation
docs: clarify USB connection steps
```

## Verification

Run `swift test` and `./Scripts/build-app.sh` on macOS before submitting a
code change. For USB protocol changes, cite the reference or hardware
observation and add a report-level test when it can catch a regression.

### Hardware check

Use a K70 RGB MK.2 Low Profile RAPIDFIRE with USB ID `1B1C:1B55` and a Mac
running macOS 14 or later. Record the macOS version, Mac chip, and keyboard
firmware version if available.

1. Open the app with the board disconnected. Check that the preview and
   profiles work and Apply is disabled.
2. Connect the board. Apply solid red, green, and blue in turn. Confirm that
   typing and media controls still work.
3. Paint `Ç`, the main Enter key, and the extra `/` key beside right Shift
   different colors. Confirm that the physical keys match after applying.
4. Try brightness at 0%, 50%, and 100%, both animations, and **Off**.
   Confirm that an animation stops when you apply another effect.
5. Save a named profile, quit, reopen the app, and load the profile.
   Check its colors, brightness, and effect settings.
6. Restore onboard lighting during an animation. Apply again and quit.
   Confirm the onboard lighting returns both times.
7. Unplug during an animation, reconnect, and apply again. Repeat after
   waking the Mac from sleep.

## Release builds

The GitHub Actions build creates an ad-hoc signed app for each architecture.
For public distribution, set `K70_SIGN_IDENTITY` to a Developer ID
Application identity before running `Scripts/build-app.sh`. Notarize and
staple the built app before publishing it. [Apple notarization guide][apple]

[commits]: https://www.conventionalcommits.org/en/v1.0.0/
[apple]: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
