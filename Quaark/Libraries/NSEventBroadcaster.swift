import MetalKit

class NSEventsState {
  var wKeyDown: Bool
  var aKeyDown: Bool
  var sKeyDown: Bool
  var dKeyDown: Bool

  init() {
    self.wKeyDown = false
    self.aKeyDown = false
    self.sKeyDown = false
    self.dKeyDown = false
  }
}

// ! WARNING: To make this class more efficient, have listeners specify which events they are listening for. Then, only broadcast to the relevant listeners. On the other hand, if there is only one listener, it probably doesn't matter.

class MTKViewWithNSEventBroadcaster : MTKView {
  var eventsState: NSEventsState
  var listeners: [NSEventListener]
  
  init(frame frameRect: CGRect) {
    self.eventsState = NSEventsState()
    self.listeners = []
    super.init(frame: frameRect, device: nil)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var acceptsFirstResponder: Bool { true }
  
  override func keyUp(with event: NSEvent) {
    self.updateStateAndBroadcastNSEvent(event: event)
  }
  
  override func keyDown(with event: NSEvent) {
    self.updateStateAndBroadcastNSEvent(event: event)
  }
  
  override func scrollWheel(with event: NSEvent) {
    self.updateStateAndBroadcastNSEvent(event: event)
  }
  
  func addListener(listener: NSEventListener) {
    self.listeners.append(listener)
  }
  
  func updateStateAndBroadcastNSEvent(event: NSEvent) {
    self.updateState(with: event)
    self.broadcastNSEvent(event: event, broadcaster: self)
  }
  
  func updateState(with event: NSEvent) {
    switch event.type {
    case .scrollWheel:
      break
    default:
      if (event.type == .keyUp || event.type == .keyDown) {
        self.updateUpDownKey(event: event)
      }
      break
    }
  }

  func updateUpDownKey(event: NSEvent) {
    assert(event.type == .keyUp || event.type == .keyDown)
    
    let keyDown: Bool = (event.type == .keyDown)
    
    switch event.charactersIgnoringModifiers {
    case "w":
      self.eventsState.wKeyDown = keyDown
    case "a":
      self.eventsState.aKeyDown = keyDown
    case "s":
      self.eventsState.sKeyDown = keyDown
    case "d":
      self.eventsState.dKeyDown = keyDown
    default:
      break
    }
  }
  
  func broadcastNSEvent(event: NSEvent, broadcaster: MTKViewWithNSEventBroadcaster) {
    for listener in listeners {
      listener.handleNSEvent(
        event: event,
        broadcaster: broadcaster
      )
    }
  }
}

protocol NSEventListener {
  func handleNSEvent(
    event: NSEvent,
    broadcaster: MTKViewWithNSEventBroadcaster
  )
}
