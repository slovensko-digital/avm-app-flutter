//
//  AppService.swift
//  Runner
//
//  Created by Matej Hlatky on 25/03/2024.
//
import Foundation
import Flutter

class AppService {
    private let methodChannelName = "digital.slovensko.avm"
    private var methodChannel: FlutterMethodChannel
    
    init(binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: binaryMessenger)
        methodChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            self?.handleMethodCall(call, result: result)
        })
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        // TODO Impl. getSharedFileName
        // TODO Impl. getSharedFile
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
