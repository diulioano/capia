import Foundation
import UIKit

@MainActor
enum CapiaImages {
    static let onsenWallpaper = loadPNG("OnsenWallpaper")
    static let welcomeCapybara = loadPNG("WelcomeCapybara")
    static let thinkingCapybara = loadPNG("ThinkingCapybara")
    static let happyCapybara = loadPNG("HappyCapybara")
    static let celebratingCapybara = loadPNG("CelebratingCapybara")

    private static func loadPNG(_ name: String) -> UIImage {
        guard let url = Bundle.module.url(forResource: name, withExtension: "png"),
              let image = UIImage(contentsOfFile: url.path) else {
            preconditionFailure("Não foi possível carregar o PNG empacotado: \(name)")
        }
        return image
    }
}
