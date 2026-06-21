import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Aplicación") {
                LabeledContent("Nombre", value: "Training Planner")
                LabeledContent("Versión", value: "0.1")
            }

            Section("Futuras ampliaciones") {
                Label("Login", systemImage: "person.crop.circle")
                Label("Sincronización en la nube", systemImage: "icloud")
                Label("Exportación PDF", systemImage: "doc.richtext")
                Label("Compartir por WhatsApp o email", systemImage: "square.and.arrow.up")
            }
        }
        .navigationTitle("Ajustes")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
