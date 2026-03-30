import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var language: String = "en" {
        didSet {
            UserDefaults.standard.set(language, forKey: "app_language")
        }
    }

    private let strings: [String: [String: String]] = [
        "status_connected": [
            "en": "Connected",
            "ru": "Подключено"
        ],
        "status_disconnected": [
            "en": "Disconnected",
            "ru": "Отключено"
        ],
        "enter_key": [
            "en": "Connection key (aivpn://...)",
            "ru": "Ключ подключения (aivpn://...)"
        ],
        "no_key": [
            "en": "No connection key set",
            "ru": "Ключ подключения не задан"
        ],
        "change": [
            "en": "Change",
            "ru": "Изменить"
        ],
        "full_tunnel": [
            "en": "Full tunnel (route all traffic)",
            "ru": "Полный туннель (весь трафик)"
        ],
        "full_tunnel_help": [
            "en": "Route all system traffic through VPN",
            "ru": "Направить весь системный трафик через VPN"
        ],
        "connect": [
            "en": "Connect",
            "ru": "Подключить"
        ],
        "disconnect": [
            "en": "Disconnect",
            "ru": "Отключить"
        ],
        "connecting": [
            "en": "Connecting...",
            "ru": "Подключение..."
        ],
        "quit": [
            "en": "Quit",
            "ru": "Выход"
        ],
        "helper_ready": [
            "en": "Service ready",
            "ru": "Сервис готов"
        ],
        "helper_missing": [
            "en": "Service not installed — reinstall AIVPN",
            "ru": "Сервис не установлен — переустановите AIVPN"
        ],
        "helper_starting": [
            "en": "Starting service...",
            "ru": "Запуск сервиса..."
        ],
    ]

    init() {
        language = UserDefaults.standard.string(forKey: "app_language") ?? Locale.current.language.languageCode?.identifier ?? "en"
        if language != "en" && language != "ru" {
            language = "en"
        }
    }

    func t(_ key: String) -> String {
        guard let dict = strings[key] else { return key }
        return dict[language] ?? dict["en"] ?? key
    }

    func toggleLanguage() {
        language = language == "en" ? "ru" : "en"
    }
}
