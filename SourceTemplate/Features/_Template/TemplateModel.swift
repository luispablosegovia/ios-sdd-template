// La lógica vive acá, no en la vista → testeable sin UI.

import Observation

@MainActor
@Observable
final class TemplateModel {
    private(set) var count = 0

    func increment() {
        count += 1
    }
}
