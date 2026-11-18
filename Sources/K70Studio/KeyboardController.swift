import Foundation
import IOKit
import IOKit.hid
import K70Core

enum KeyboardStatus: Equatable, Sendable {
    case searching
    case preview
    case disconnected
    case multipleDevices
    case available
    case applied(LightingSettings)
    case failed(String)

    var appliedSettings: LightingSettings? {
        if case let .applied(settings) = self { return settings }
        return nil
    }

    var canApply: Bool {
        switch self {
        case .available, .applied, .failed: return true
        default: return false
        }
    }
}

private struct USBFailure: LocalizedError {
    let operation: String
    let code: IOReturn

    var errorDescription: String? {
        let hexCode = String(format: "0x%08X", UInt32(bitPattern: code))
        return "\(operation) failed (\(hexCode)). Quit other RGB apps and reconnect the keyboard."
    }
}

// All HID handles, timers, and reports are confined to queue.
final class KeyboardController: @unchecked Sendable {
    private struct Device {
        let id: UInt64
        let handle: IOHIDDevice
    }

    private let queue = DispatchQueue(label: "app.k70studio.hid", qos: .userInitiated)
    private let onStatus: @MainActor @Sendable (KeyboardStatus) -> Void
    private var device: Device?
    private var opened: IOHIDDevice?
    private var scanTimer: DispatchSourceTimer?
    private var animationTimer: DispatchSourceTimer?
    private var status: KeyboardStatus = .searching

    init(preview: Bool, onStatus: @escaping @MainActor @Sendable (KeyboardStatus) -> Void) {
        self.onStatus = onStatus

        queue.async { [self] in
            guard !preview else {
                publish(.preview)
                return
            }
            let timer = DispatchSource.makeTimerSource(queue: queue)
            timer.schedule(deadline: .now(), repeating: .seconds(2), leeway: .milliseconds(200))
            timer.setEventHandler { [weak self] in
                guard let self, let change = scan() else { return }
                publish(change)
            }
            scanTimer = timer
            timer.resume()
        }
    }

    func apply(_ settings: LightingSettings) {
        queue.async { [self] in
            guard scanTimer != nil else { return }
            let change = scan()
            guard let device else {
                publish(change ?? .disconnected, force: true)
                return
            }
            stopAnimation()
            do {
                if opened == nil {
                    let result = IOHIDDeviceOpen(device.handle, IOOptionBits(kIOHIDOptionsTypeNone))
                    guard result == kIOReturnSuccess else {
                        throw USBFailure(operation: "Opening the lighting interface", code: result)
                    }
                    opened = device.handle
                }
                guard let opened else { return }
                try write(LightingReports.begin, to: opened)
                Thread.sleep(forTimeInterval: 0.03)
                try sendFrame(settings, elapsed: 0, to: opened)
                publish(.applied(settings), force: true)

                if settings.effect.isAnimated {
                    startAnimation(settings)
                }
            } catch {
                fail(error)
            }
        }
    }

    func restore() {
        queue.async { [self] in
            guard opened != nil else {
                publish(status, force: true)
                return
            }
            do {
                try endSession(restore: true)
                publish(.available)
            } catch {
                publish(.failed(error.localizedDescription), force: true)
            }
        }
    }

    func shutDown(then completion: @escaping @MainActor @Sendable () -> Void) {
        queue.async { [self] in
            scanTimer?.cancel()
            scanTimer = nil
            try? endSession(restore: true)
            device = nil
            DispatchQueue.main.async { completion() }
        }
    }

    private func scan() -> KeyboardStatus? {
        // Enumerate without opening a manager, registering input callbacks, or seizing any service.
        let manager: IOHIDManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let matching: [String: Any] = [
            kIOHIDVendorIDKey: LightingReports.vendorID,
            kIOHIDProductIDKey: LightingReports.productID,
            kIOHIDTransportKey: "USB",
            kIOHIDPrimaryUsagePageKey: LightingReports.usagePage
        ]
        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)

        let interfaces = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> ?? []
        let devices = interfaces.compactMap { handle -> Device? in
            let page = IOHIDDeviceGetProperty(handle, kIOHIDPrimaryUsagePageKey as CFString) as? NSNumber
            let size = IOHIDDeviceGetProperty(handle, kIOHIDMaxOutputReportSizeKey as CFString) as? NSNumber
            guard page?.intValue == LightingReports.usagePage,
                  let size, size.intValue >= LightingReports.reportLength else { return nil }
            var id: UInt64 = 0
            guard IORegistryEntryGetRegistryEntryID(IOHIDDeviceGetService(handle), &id) == kIOReturnSuccess
            else { return nil }
            return Device(id: id, handle: handle)
        }

        let next = devices.count == 1 ? devices.first : nil
        if let next, next.id == device?.id { return nil }

        let previousIsPresent = devices.contains { $0.id == device?.id }
        try? endSession(restore: previousIsPresent)
        device = next
        if devices.count > 1 { return .multipleDevices }
        return next == nil ? .disconnected : .available
    }

    private func startAnimation(_ settings: LightingSettings) {
        let start = ProcessInfo.processInfo.systemUptime
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + .milliseconds(50), repeating: .milliseconds(50),
                       leeway: .milliseconds(4))
        timer.setEventHandler { [weak self] in
            guard let self, let opened else { return }
            do {
                try sendFrame(settings, elapsed: ProcessInfo.processInfo.systemUptime - start, to: opened)
            } catch {
                fail(error)
            }
        }
        animationTimer = timer
        timer.resume()
    }

    private func stopAnimation() {
        animationTimer?.cancel()
        animationTimer = nil
    }

    private func sendFrame(_ settings: LightingSettings, elapsed: TimeInterval, to handle: IOHIDDevice) throws {
        for report in LightingReports.encode(frame: settings.frame(elapsed: elapsed)) {
            try write(report, to: handle)
        }
    }

    private func write(_ report: [UInt8], to handle: IOHIDDevice) throws {
        // The vendor output report is unnumbered. Its 64 bytes start with the command byte.
        let result = IOHIDDeviceSetReport(handle, kIOHIDReportTypeOutput, 0, report, report.count)
        guard result == kIOReturnSuccess else {
            throw USBFailure(operation: "Sending a USB report", code: result)
        }
    }

    private func endSession(restore: Bool) throws {
        stopAnimation()
        guard let handle = opened else { return }
        defer {
            IOHIDDeviceClose(handle, IOOptionBits(kIOHIDOptionsTypeNone))
            opened = nil
        }
        if restore {
            try? write(LightingReports.restore, to: handle)
            Thread.sleep(forTimeInterval: 0.03)
            try write(LightingReports.restore, to: handle)
        }
    }

    private func fail(_ error: Error) {
        try? endSession(restore: true)
        publish(.failed(error.localizedDescription), force: true)
    }

    private func publish(_ next: KeyboardStatus, force: Bool = false) {
        guard force || status != next else { return }
        status = next
        DispatchQueue.main.async { [onStatus] in onStatus(next) }
    }
}
