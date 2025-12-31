import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                RadioStationListView()

                NowPlayingView()
            }
            .navigationTitle("Simple Radio")
        }
    }
}

#Preview {
    ContentView()
}
