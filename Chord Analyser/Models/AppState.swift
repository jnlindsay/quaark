/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The MIDI-CI discovery app state object.
*/

import Foundation
import Logger

// MARK: - AppState

class AppState {
    
    let receiverOptions: ReceiverOptions
//    let logModel: LogModel
    let receiverManager: PacketReceiver
    
    init(receiverOptions: ReceiverOptions = .init() /*, logModel: LogModel = .init()*/) {
        log(.routine, "App state initialised.")
        self.receiverOptions = receiverOptions
//        self.logModel = logModel
        self.receiverManager = PacketReceiver(receiverOptions: receiverOptions/*, logModel: logModel*/)
    }
    
}
