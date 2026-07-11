// _Template — patrón de referencia para toda feature nueva.
// Copiá esta carpeta, renombrá (carpeta + tipos) y borrá este comentario.

import SwiftUI

struct TemplateView: View {
    @State private var model = TemplateModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Contador: \(model.count)", comment: "Template counter label")
                .font(.title2)

            Button {
                model.increment()
            } label: {
                Label("Sumar", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Incrementa el contador en uno")
        }
        .padding()
    }
}

#Preview {
    TemplateView()
}
