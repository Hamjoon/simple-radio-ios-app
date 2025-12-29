import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "radio")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Simple Radio")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
