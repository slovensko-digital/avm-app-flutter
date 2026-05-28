//
//  AppService.swift
//  Runner
//
//  Created by Matej Hlatky on 25/03/2024.
//
import Foundation
import Flutter

/// Provides functionality for Flutter app:
///  - `getFile(String)` - returns absolute file path from file:// URI
///  -  "incomingUri" events - emits URIs to file shared to app
class AppService : NSObject, FlutterStreamHandler {

    /// `FlutterMethodChannel`  for all methods.
    private var methods: FlutterMethodChannel

    /// `FlutterEventChannel` for all events.
    private var events: FlutterEventChannel

    /// `FlutterEventSink`  for "incomingUri".
    private var incomingUriSink: FlutterEventSink?

    /// Stores the value before `incomingUriSink` was initialized.
    private var incomingUri: String?

    init(binaryMessenger: FlutterBinaryMessenger) {
        methods = FlutterMethodChannel(name: "digital.slovensko.avm", binaryMessenger: binaryMessenger)
        events = FlutterEventChannel(name: "digital.slovensko.avm/events", binaryMessenger: binaryMessenger)

        super.init(); // NSObject

        methods.setMethodCallHandler(handleMethodCall)
        events.setStreamHandler(self)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if ((arguments as? String) == "incomingUri") {
            incomingUriSink = events

            if (incomingUri != nil) {
                incomingUriSink?(incomingUri)
                incomingUri = nil
            }
        }

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if ((arguments as? String) == "incomingUri") {
            incomingUriSink?(FlutterEndOfEventStream)
            incomingUriSink = nil
        }

        return nil
    }

    func onNewUri(url: URL) -> Bool {
        if (url.isFileURL || ["https", "avm"].contains(url.scheme)) {
            if (!isAllowedFileUri(url)) {
                NSLog("[AppService] onNewUri: dropping disallowed file:// URI")
                return false
            }

            if (incomingUriSink != nil) {
                incomingUriSink!(url.absoluteString)
            } else {
                incomingUri = url.absoluteString
            }

            return true
        }

        return false
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "getFile": onGetFile(value: call.arguments as! String, result: result)
            case "isAllowedFileUri": onIsAllowedFileUri(value: call.arguments as! String, result: result)
            default: result(FlutterMethodNotImplemented)
        }
    }

    private func onGetFile(value: String, result: @escaping FlutterResult) {
        do {
            guard let sourceFile: URL = URL(string: value) else {
                preconditionFailure("Unable to parse path as URL.")
            }

            precondition(sourceFile.isFileURL, "Path is not 'file://' scheme.")

            guard isAllowedFileUri(sourceFile) else {
                result(FlutterError(code: "GET_FILE_ERROR", message: "file:// URI inside app container is not allowed", details: nil))
                return
            }

            sourceFile.startAccessingSecurityScopedResource() // this might return false when it' not needed, so dont' check it!
            defer { sourceFile.stopAccessingSecurityScopedResource() }

            let fileManager = FileManager.default

            // Cache directory
            let outputDirectory: URL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

            // New file
            let fileName: String = sourceFile.lastPathComponent
            let outputFile: URL = outputDirectory.appendingPathComponent(fileName)
            try fileManager.copyItem(at: sourceFile, to: outputFile)

            // Return new file path without leading "file://"
            result(outputFile.path)
        } catch let error {
            result(FlutterError(code: "GET_FILE_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    private func onIsAllowedFileUri(value: String, result: @escaping FlutterResult) {
        guard let url = URL(string: value) else {
            result(FlutterError(code: "IS_ALLOWED_FILE_URI_ERROR", message: "Unable to parse URI", details: nil))
            return
        }
        result(isAllowedFileUri(url))
    }

    /// Returns `true` if `url` is safe to surface to Dart.
    ///
    /// Non-`file://` schemes pass through unchanged. `file://` URIs are
    /// rejected when they point inside the app's own sandbox container
    /// (Documents, Library/Preferences, tmp, …) to prevent a malicious
    /// app from reading our private data by sharing a crafted `file://` URI.
    ///
    /// Both paths are resolved through symlinks before comparison
    /// (`/var` → `/private/var` on iOS) to defeat path-traversal attacks.
    private func isAllowedFileUri(_ url: URL) -> Bool {
        guard url.isFileURL else { return true }

        // NSHomeDirectory() is the app's sandbox root; resolve symlinks so that
        // /var/mobile/... and /private/var/mobile/... compare equal.
        let appContainer = URL(fileURLWithPath: NSHomeDirectory()).resolvingSymlinksInPath()
        let fileURL = url.resolvingSymlinksInPath()
        let containerPath = appContainer.path

        return !fileURL.path.hasPrefix(containerPath + "/") && fileURL.path != containerPath
    }
}
