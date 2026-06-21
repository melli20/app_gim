import SwiftUI

struct AppRootView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.contentView
                }
                .tabItem { tab.label }
                .tag(tab)
            }
        }
    }
}

#Preview {
    AppRootView()
}
