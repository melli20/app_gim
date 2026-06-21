import SwiftUI

struct PlanHistoryView: View {
    var body: some View {
        ContentUnavailableView(
            "Historial",
            systemImage: "clock.arrow.circlepath",
            description: Text("El historial y duplicado se implementarán en la Fase 6.")
        )
        .navigationTitle("Historial")
    }
}

#Preview {
    NavigationStack {
        PlanHistoryView()
    }
}
