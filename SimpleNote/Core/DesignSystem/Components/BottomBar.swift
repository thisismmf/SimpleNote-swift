import SwiftUI

struct BottomBar<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        TabView {
            content
        }
    }
}
