import Foundation

struct EnvironmentModel: Sendable {
    var aqi: Int
    var temperatureC: Double
    var uvIndex: Double
    var co2ppm: Int
    var noiseDB: Double
    var timestamp: Date
}

extension EnvironmentModel {
    static let placeholder = EnvironmentModel(
        aqi: 42,
        temperatureC: 22.0,
        uvIndex: 1.0,
        co2ppm: 600,
        noiseDB: 38.0,
        timestamp: .now
    )
}

enum EnvironmentState: Equatable, Sendable {
    case calm
    case alert(reason: AlertReason)

    enum AlertReason: String, Sendable {
        case highUV
        case highCO2
        case highNoise
        case poorAir
    }

    static func derive(from env: EnvironmentModel) -> EnvironmentState {
        if env.uvIndex >= 7 { return .alert(reason: .highUV) }
        if env.co2ppm >= 1200 { return .alert(reason: .highCO2) }
        if env.noiseDB >= 70 { return .alert(reason: .highNoise) }
        if env.aqi >= 100 { return .alert(reason: .poorAir) }
        return .calm
    }
}
