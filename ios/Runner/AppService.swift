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
        
        // TODO Also make self implement FlutterMethodCallHandler
        methods.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.handleMethodCall(call, result: result)
        })
        
        events.setStreamHandler(self);
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
            // TODO Call sharedFileSink.endOfStream
            incomingUriSink = nil
        }
        
        return nil
    }
    
    func onNewUri(url: URL) -> Bool {
        if (url.isFileURL) {
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
        case "getFile": onGetFile(value: call.arguments as! String, result: result);
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    private func onGetFile(value: String, result: @escaping FlutterResult) {
        do {
            guard let sourceFile: URL = URL(string: value) else {
                preconditionFailure("Unable to parse path as URL.")
            }
 
            precondition(sourceFile.isFileURL, "Path is not 'file://' scheme.")
            sourceFile.startAccessingSecurityScopedResource() // this might return false when it' not needed, so dont' check it!
            
            let fileManager = FileManager.default
            
            // Cache directory
            let outputDirectory: URL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
            
            // New file
            let fileName: String = sourceFile.lastPathComponent
            let outputFile: URL = outputDirectory.appendingPathComponent(fileName)
            try fileManager.copyItem(at: sourceFile, to: outputFile)
            
            // TODO Put to finally block
            sourceFile.stopAccessingSecurityScopedResource()
            
            // Return new file path without leading "file://"
            result(outputFile.path)
        } catch let error {
            result(FlutterError(code: "GET_FILE_ERROR", message: error.localizedDescription, details: nil))
        }
    }
}
