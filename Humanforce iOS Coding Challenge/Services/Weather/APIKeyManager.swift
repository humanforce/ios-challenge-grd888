import Foundation

struct APIKeyManager {
    static var weatherAPIKey: String {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil),
              let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            fatalError("Could not find .env file")
        }

        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let components = line.components(separatedBy: "=")
            if components.count == 2,
               components[0] == "OPEN_WEATHER_MAP_API_KEY" {
                return components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        fatalError("API Key not found in .env file")
    }
}
