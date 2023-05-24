//
//  ContentView.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct KeyboardView : View {

  var stuff = "Hello"
  
  @Environment(\.openWindow) private var openWindow
  @ObservedObject var keyboardModel: KeyboardModel
  @ObservedObject var settings: Settings
  var midiConnection: CoreMIDIConnection
  private var world: GraphicsWorld // TODO: it makes sense for KeyboardView to directly operate the metal view controller, instead of touching the graphics world
  
  init(
    keyboardModel: KeyboardModel,
    midiConnection: CoreMIDIConnection,
    world: GraphicsWorld,
    settings: Settings
  ) {
    self.keyboardModel = keyboardModel
    self.midiConnection = midiConnection
    self.world = world
    self.settings = settings
  }
  
  var body: some View {
    VStack {
      Spacer()
      Text(String(keyboardModel.getChordName()))
        .font(.largeTitle)
//      Spacer()
//      Text("Dissonance: " + String(keyboardModel.getDissonance()))
      Spacer()
      Button("MetalView") {
        openWindow(id: "metalView")
      }
//      Spacer()
//      ImportModelView(midiConnection: midiConnection, world: world)
      Spacer()
      LightIntensitySlider(settings: self.settings)
      Spacer()
      MIDIInputPickerView(midiConnection: self.midiConnection)
      Spacer()
      PhantomKeyboardView(
        keyboardModel: keyboardModel
      )
    }
  }
}

//struct ImportModelView : View {
//  
//  @State private var importing = false
//  var midiConnection: CoreMIDIConnection
//  var world: GraphicsWorld
//  
//  init(midiConnection: CoreMIDIConnection, world: GraphicsWorld) {
//    self.midiConnection = midiConnection
//    self.world = world
//  }
//  
//  var body: some View {
//    Button("Import .obj model") { importing = true }
//      .fileImporter(
//        isPresented: $importing,
//        allowedContentTypes: [UTType(filenameExtension: "obj")]
//          .compactMap{ $0 },
//        allowsMultipleSelection: false
//    ) { result in
//      switch result {
//      case .success(let files):
//        print(files[0].path)
//        self.world.models =
//        [GraphicsModel(url: files[0].path)]
//        self.world.reconfigureMeshes()
//      case .failure(let error):
//        print(error.localizedDescription)
//      }
//    }
//  }
//}

struct LightIntensitySlider : View {
  
  @ObservedObject var settings: Settings
//  @State private var speed = 50.0
  @State private var isEditing = false
  
  var body: some View {
    VStack{
      Slider(
        value: $settings.lightIntensity,
        in: 0...1,
        onEditingChanged: { editing in
          isEditing = editing
        }
      )
      .frame(width: 200)
      Text("\(settings.lightIntensity)")
        .foregroundColor(isEditing ? .red : .blue)
    }
  }
}

struct MIDIInputPickerView : View {
  
  @State private var selection: MIDIEndpointRef?
  @ObservedObject var midiConnection: CoreMIDIConnection
  
  init(midiConnection: CoreMIDIConnection) {
    self.midiConnection = midiConnection
    self._selection = State<MIDIEndpointRef?>(initialValue: self.midiConnection.source)
  }
  
  var body: some View {
    Picker("Choose MIDI input:", selection: self.$selection) {
      Text("None").tag(nil as MIDIEndpointRef?)
      ForEach(Array(self.midiConnection.sources.keys), id: \.self) { source in
        Text(midiConnection.sources[source]!).tag(source as MIDIEndpointRef?)
      }
    }
    .frame(width: 250)
    .onChange(of: self.selection) { newSource in
      if let source = newSource {
        midiConnection.changeSourceTo(source: source)
      } else {
        midiConnection.disconnectSource()
      }
    }
    .onChange(of: self.midiConnection.source) { source in
      self.selection = source
    }
  }
  
}

// The word "phantom" indicates the "missing" black keys on the
//   keyboard are drawn but have a "clear" colour.
struct PhantomKeyboardView : View {
    
  private let keyOnColour = Color.teal
  @ObservedObject var keyboardModel: KeyboardModel
  
  // 52 white keys
  private let whiteKeyToNote: [Int32] = [ // Note: the index of 59, for example, gives MIDI note 60 (middle C)
    20, 22,                             // 0th octave
    23, 25, 27,     28,  30,  32,  34,  // 1st
    35, 37, 39,     40,  42,  44,  46,  // 2nd
    47, 49, 51,     52,  54,  56,  58,  // 3rd
    59, 61, 63,     64,  66,  68,  70,  // 4th
    71, 73, 75,     76,  78,  80,  82,  // 5th
    83, 85, 87,     88,  90,  92,  94,  // 6th
    95, 97, 99,    100, 102, 104, 106,  // 7th
    107
  ]
  
  // given a note that may be phantom or black, the MIDI note is returned
  private let blackKeyToNote: [Int: Int32] = [
    // 15 phantom keys at the following positions:
    //     1, 4, 8, 11, 15, 18, 22, 25, 29, 32, 36, 39, 43, 46, 50
    
    // 36 black keys
     0: 21,                                        // 0th octave
     2: 24,  3: 26,     5:  29,  6:  31,  7:  33,  // 1st
     9: 36, 10: 38,    12:  41, 13:  43, 14:  45,  // 2nd
    16: 48, 17: 50,    19:  53, 20:  55, 21:  57,  // 3rd
    23: 60, 24: 62,    26:  65, 27:  67, 28:  69,  // 4th
    30: 72, 31: 74,    33:  77, 34:  79, 35:  81,  // 5th
    37: 84, 38: 86,    40:  89, 41:  91, 42:  93,  // 6th
    44: 96, 45: 98,    47: 101, 48: 103, 49: 105   // 7th
  ]
  
  func phantomOrBlackKeyToColour(i: Int) -> Color {
    let maybeNote: Int32? = blackKeyToNote[i]
    if let note = maybeNote {
      return keyboardModel.getNotesOnOff(Int(note)) ? keyOnColour : .black
    } else {
      return .clear
    }
  }
  
  var body: some View {
    VStack {
      ZStack {
        // Background
        Rectangle()
          .fill(.gray)
          // Note: a keyboard has 52 white keys.
          // 571 = (52 * 10 + 1) - 1
          .frame(width: 571, height: 100)
        
        // White keys
        ForEach(0..<52) {
          Rectangle()
            .fill(keyboardModel.getNotesOnOff(Int(whiteKeyToNote[$0])) ? keyOnColour : .white)
            .frame(width: 10, height: 100)
            // -281 = -(572 / 2) + 5
            .offset(x: -280.5 + CGFloat($0) * 11)
        }
        
        // Black keys (including phantom keys)
        ForEach(0..<51) {
          Rectangle()
            .fill(phantomOrBlackKeyToColour(i: $0))
            .frame(width: 7, height: 60)
            .offset(x: -280.5 + 5.5 + CGFloat($0) * 11, y: -20)
        }
      }
    }
  }
}
