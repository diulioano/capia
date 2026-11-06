/// Valor monetário em centavos inteiros de real. Nunca usa ponto flutuante.
public struct Cents: Hashable, Comparable, Codable, Sendable {
    public static let zero = Cents(0)
    /// R$ 999.999.999,99: onze algarismos, como no campo de saldo do design.
    public static let max = Cents(99_999_999_999)
    public static let maxDigits = 11

    public let value: Int64

    /// Limita o valor ao intervalo aceito pelo protótipo (0 até `max`).
    public init(_ value: Int64) {
        self.value = Swift.min(Swift.max(value, 0), 99_999_999_999)
    }

    public init(reais: Int64) {
        self.init(reais.multipliedReportingOverflow(by: 100).overflow ? Int64.max : reais * 100)
    }

    /// Converte o texto digitado em centavos: mantém só algarismos ASCII, descarta zeros
    /// à esquerda e conserva os onze primeiros, preenchendo da direita para a esquerda.
    public init(typed text: String) {
        let digits = text.unicodeScalars
            .filter { $0.value >= 48 && $0.value <= 57 }
            .map { Int64($0.value - 48) }
            .drop { $0 == 0 }
            .prefix(Cents.maxDigits)
        self.init(digits.reduce(Int64(0)) { $0 * 10 + $1 })
    }

    /// Soma que satura no limite em vez de ultrapassá-lo.
    public func adding(_ other: Cents) -> Cents {
        Cents(value + other.value)
    }

    public static func < (lhs: Cents, rhs: Cents) -> Bool { lhs.value < rhs.value }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int64.self)
        guard raw >= 0, raw <= Cents.max.value else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                    debugDescription: "Centavos fora do intervalo: \(raw)"))
        }
        self.init(raw)
    }
}

/// Formatação brasileira determinística, igual no Linux e no iPhone.
public enum BRL {
    /// `R$ 1.234,56`
    public static func format(_ cents: Cents) -> String {
        let reais = cents.value / 100
        let rest = cents.value % 100
        return "R$ \(grouped(reais)),\(rest < 10 ? "0" : "")\(rest)"
    }

    /// Rótulo dos atalhos do saldo, sem `,00`: `+ R$ 1.000`.
    public static func shortcutLabel(reais: Int64) -> String {
        "+ R$ \(grouped(reais))"
    }

    private static func grouped(_ value: Int64) -> String {
        let digits = Array(String(value))
        var result = ""
        for (index, digit) in digits.enumerated() {
            if index > 0, (digits.count - index) % 3 == 0 { result.append(".") }
            result.append(digit)
        }
        return result
    }
}
