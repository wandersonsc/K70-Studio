# K70 Studio

[![macOS CI][ci-badge]][ci-workflow]

K70 Studio is a native macOS RGB lighting editor for the **Corsair K70 RGB
MK.2**. The keyboard preview uses the Brazilian ABNT2 layout.

| Model | USB ID |
| --- | --- |
| K70 RGB MK.2 | `1B1C:1B49` |
| K70 RGB MK.2 Low Profile RAPIDFIRE ([CH-9109018-BR][corsair]) | `1B1C:1B55` |

- Set a solid color or paint individual keys in the keyboard preview.
- Adjust brightness and choose solid, per-key, breathing, rainbow, or off.
- Save named profiles on your Mac and preview changes without a keyboard.
- Apply lighting over USB and return to the keyboard’s built-in lighting.

## Install

K70 Studio requires **macOS 14 or later** on an Apple Silicon or Intel Mac.
The GitHub builds use native Liquid Glass controls on macOS 26 and
translucent SwiftUI materials on earlier supported versions.

### Download a CI build

Open a successful **macOS CI** run and select the artifact for your Mac from
**Artifacts**. Choose `arm64` for Apple Silicon or `x86_64` for Intel.
Extract the download and the app ZIP inside it. CI builds are signed for
development use. [macOS CI runs][ci-workflow]

### Build locally

Install Xcode or Xcode Command Line Tools with **Swift 5.10 or later**.
Run `xcode-select --install` if you need the command-line tools.

Run these commands from the repository root.

```bash
./Scripts/build-app.sh
open "dist/K70 Studio.app"
```

You can move the locally signed app to Applications. To launch with USB
disabled, use `open -n "dist/K70 Studio.app" --args --preview`.

## Use K70 Studio

1. Connect the keyboard’s USB plug. The second plug is for USB passthrough.
   Use a data-capable adapter if you need USB-C.
2. Quit other apps that are controlling the keyboard’s RGB. If macOS asks
   whether to allow the USB accessory, allow it on your Mac.
3. Pick an effect or click a key in the preview to edit its color.
   **Use Base Color** removes that key’s override.
4. Click **Apply to Keyboard**. Keep the app open for animations. Click
   **Restore Onboard Lighting** to resume the keyboard’s built-in profile.

The app sends temporary lighting changes and keeps named profiles in macOS
user defaults. The app attempts to restore onboard lighting on normal quit.
Its controls cover lighting, brightness, and local profiles.

## Troubleshooting

If the board is missing, look for `0x1B49` or `0x1B55` under
**System Information → USB** and reconnect the keyboard directly.
**Lighting interface unavailable** means macOS sees the supported keyboard
but the app cannot find its RGB
interface. If you see this status or a USB error, quit
other RGB utilities and reconnect before retrying. Unplug and reconnect if
the board stays in software lighting mode after a forced quit.

## Development

Open `Package.swift` in Xcode. Run `swift test` to check the key layout,
color and effect behavior, profile serialization, and USB report bytes.
The core tests also run on Linux. GitHub Actions runs the tests on Intel
macOS and builds the app for both Mac architectures.
[Contribution guide](CONTRIBUTING.md)

`K70Core` renders lighting and encodes Corsair NXP reports. The app opens the
vendor HID lighting interface through IOKit in shared mode and leaves input
handling with macOS. It makes no network calls.

## License and references

K70 Studio is an independent project licensed under GPL-2.0-only.
[License](LICENSE)

The wire format, LED addresses, and HID interface use the following
references.

- [ckb-next protocol notes][protocol]
- [ckb-next device source][ckb-source]
- [OpenRGB device detection][openrgb]

[ci-badge]: https://github.com/wandersonsc/K70-Studio/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/wandersonsc/K70-Studio/actions/workflows/ci.yml
[corsair]: https://www.corsair.com/br/pt/p/keyboards/ch-9109018-br/k70-rgb-mk-2-low-profile-rapidfire-mechanical-gaming-keyboard-cherry-mx-low-profile-speed-br-ch-9109018-br
[protocol]: https://github.com/ckb-next/ckb-next/wiki/Maintainers-Corsair-Protocol
[ckb-source]: https://github.com/ckb-next/ckb-next/tree/e22eaf2fba7f93764b4c6d4413bb83eeca75d10a/src/daemon
[openrgb]: https://gitlab.com/CalcProgrammer1/OpenRGB/-/blob/master/Controllers/CorsairPeripheralController/CorsairPeripheralControllerDetect.cpp
