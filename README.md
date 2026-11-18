# K70 Studio

K70 Studio is a native SwiftUI lighting editor for the **Corsair K70 RGB MK.2 Low Profile RAPIDFIRE**, Brazilian ABNT2 model **CH-9109018-BR**. It targets USB ID **1B1C:1B55**.

- Paint individual keys in a Brazilian keyboard preview or set a solid color across the board.
- Adjust brightness and choose between solid, per-key, breathing, rainbow, and off.
- Save and load named lighting profiles on your Mac.
- Preview edits offline. **Apply to Keyboard** sends the current preview over USB. **Restore Onboard Lighting** returns lighting to the keyboard’s built-in profile.

The app controls temporary lighting. Profiles live in macOS user defaults. Key remapping, macro editing, firmware updates, and onboard profile editing are outside the app’s scope.

## Build on your Mac

You need **macOS 14 or later** and Xcode or Xcode Command Line Tools with **Swift 5.10 or later**. Run `xcode-select --install` if you need the command-line tools.

From the extracted `K70-Studio` folder, run:

```bash
./Scripts/build-app.sh
open "dist/K70 Studio.app"
```

The script builds a locally signed app for the Mac you run it on. You can move the app to Applications after building it. To open an offline preview with USB disabled, run:

```bash
open -n "dist/K70 Studio.app" --args --preview
```

You can also open `Package.swift` in Xcode to edit the project.

## Use the keyboard

1. Plug in the USB connector marked for the keyboard. The other plug is for USB passthrough. Use a data-capable USB adapter if your Mac has USB-C ports.
2. Quit other apps that are controlling the keyboard’s RGB. If macOS asks whether to allow the USB accessory, allow it on your Mac.
3. Pick an effect and edit the keyboard preview. Click a key to switch to **Per-key** and set its own color. **Use Base Color** removes that key’s override.
4. Click **Apply to Keyboard**. Keep the app open for animated effects. Use **Restore Onboard Lighting** to let the keyboard resume its built-in lighting. The app also attempts restoration on normal quit.

If detection fails, confirm `0x1B55` in **System Information → USB**, reconnect the keyboard directly, and relaunch. If the app reports a USB error, quit other RGB utilities and reconnect before retrying. Reconnecting also returns a keyboard left in software mode after a forced quit to its onboard lighting.

## Verify and publish on GitHub

Run `swift test` to check the layout, color and effect behavior, profile serialization, and exact USB report encoding. The core tests also run on Linux. The [hardware checklist](CONTRIBUTING.md#hardware-check) covers the live behavior separately.

Push the project, including the hidden `.github` directory, to your GitHub repository with `main` as the default branch. The **macOS CI** workflow tests and builds Apple Silicon and Intel variants. Download the app archive for your Mac’s chip from the run’s **Artifacts**. For public releases, use a Developer ID identity via `K70_SIGN_IDENTITY` and notarize the signed bundle before distribution.

## How it works

`K70Core` renders lighting and encodes the Corsair NXP 24-bit reports. The macOS app uses IOKit to open the keyboard’s vendor HID lighting interface in shared mode. It sends lighting output reports and leaves input handling with macOS. The app has no runtime dependencies, network calls, or telemetry.

The target model and key positions follow the [Corsair product page](https://www.corsair.com/br/pt/p/keyboards/ch-9109018-br/k70-rgb-mk-2-low-profile-rapidfire-mechanical-gaming-keyboard-cherry-mx-low-profile-speed-br-ch-9109018-br). The wire format and LED addresses use the [ckb-next protocol notes](https://github.com/ckb-next/ckb-next/wiki/Maintainers-Corsair-Protocol), [ckb-next source](https://github.com/ckb-next/ckb-next/tree/e22eaf2fba7f93764b4c6d4413bb83eeca75d10a/src/daemon), and [OpenRGB device detection](https://gitlab.com/CalcProgrammer1/OpenRGB/-/blob/master/Controllers/CorsairPeripheralController/CorsairPeripheralControllerDetect.cpp) as references. K70 Studio is an independent project.

Licensed under [GPL-2.0-only](LICENSE).
