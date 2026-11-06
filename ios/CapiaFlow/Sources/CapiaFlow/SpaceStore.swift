import Foundation

/// Guarda o espaço configurado em um único documento JSON no aparelho.
/// Não sincroniza com o iCloud; isso será uma funcionalidade própria.
public struct SpaceStore: Sendable {
    public static let fileName = "space.json"

    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    public var fileURL: URL { directory.appendingPathComponent(Self.fileName) }

    /// Devolve `nil` para arquivo ausente, ilegível ou de versão desconhecida.
    /// Nunca apaga o arquivo existente.
    public func load() -> ConfiguredSpace? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let version = try? decoder.decode(SchemaProbe.self, from: data),
              version.schemaVersion == ConfiguredSpace.currentSchemaVersion,
              let space = try? decoder.decode(ConfiguredSpace.self, from: data),
              !space.accounts.isEmpty else { return nil }
        return space
    }

    /// Grava de forma atômica, criando o diretório se necessário.
    public func save(_ space: ConfiguredSpace) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(space)
        #if os(iOS)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: fileURL, options: [.atomic])
        #endif
    }

    private struct SchemaProbe: Decodable {
        let schemaVersion: Int
    }
}
