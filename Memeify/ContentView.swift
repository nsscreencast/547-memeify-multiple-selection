import SwiftUI

final class AppModel: ObservableObject {
    @Published var image: NSImage? = NSImage(named: "decision")
    @Published var textElements: [TextElement] = []
    @Published var selection: Set<TextElement.ID> = []

    var selectedTextElements: Binding<[TextElement]> {
        .init(
            get: {
                self.textElements.filter { self.selection.contains($0.id) }
            },
            set: { newElements in
                newElements.forEach { el in
                    if let idx = self.textElements.firstIndex(where: { $0.id == el.id }) {
                        self.textElements[idx] = el
                    }
                }
            }
        )
    }

    func selectionBinding(for element: TextElement) -> Binding<Bool> {
        .init(
            get: { self.selection.contains(element.id) },
            set: { newValue in
                if newValue {
                    self.selection.insert(element.id)
                } else {
                    self.selection.remove(element.id)
                }
            }
        )
    }

}

struct ContentView: View {
    @Binding var document: MemeifyDocument
    @StateObject var appModel = AppModel()

    var body: some View {
        HSplitView {
            CanvasView(appModel: appModel)
            InspectorView(textElements: appModel.selectedTextElements)
        }
    }
}

struct InspectorView: View {
    @Binding var textElements: [TextElement]

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
            VStack {
                Button("Text") {
                    $textElements.forEach { $0.wrappedValue.text = "updated!" }
                }
                .disabled(textElements.isEmpty)
            }.padding()
        }
        .frame(width: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(MemeifyDocument()))
    }
}
