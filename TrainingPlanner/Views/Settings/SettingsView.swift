import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Aplicación") {
                LabeledContent("Nombre", value: "Training Planner")
                LabeledContent("Versión", value: "1.0")
                LabeledContent("Almacenamiento", value: "Local con SwiftData")
            }

            Section("Datos iniciales") {
                Label("10 ejercicios de ejemplo cargados automáticamente", systemImage: "checkmark.seal")
                Label("Sin backend en esta versión", systemImage: "iphone")
            }

            Section("Preparada para ampliar") {
                Label("Login", systemImage: "person.crop.circle")
                Label("Sincronización en la nube", systemImage: "icloud")
                Label("Exportación PDF", systemImage: "doc.richtext")
                Label("Compartir por WhatsApp o email", systemImage: "square.and.arrow.up")
                Label("Panel web de administración", systemImage: "desktopcomputer")
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
