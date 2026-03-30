import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vpn: VPNManager
    @EnvironmentObject var loc: LocalizationManager

    @State private var connectionKey: String = ""
    @State private var showKeyInput: Bool = false
    @State private var fullTunnel: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("AIVPN")
                    .font(.headline)
                Spacer()
                // Language toggle
                Button(action: { loc.toggleLanguage() }) {
                    Text(loc.language == "en" ? "🇷🇺" : "🇬🇧")
                        .font(.title3)
                        .buttonStyle(.plain)
                }
                .buttonStyle(.plain)
                .help(loc.language == "en" ? "Русский" : "English")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Helper status indicator
            HStack {
                Circle()
                    .fill(vpn.helperAvailable ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(vpn.helperAvailable
                     ? loc.t("helper_ready")
                     : loc.t("helper_missing"))
                    .font(.caption2)
                    .foregroundColor(vpn.helperAvailable ? .secondary : .orange)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 2)

            // Connection status
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(vpn.isConnected ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                    Text(vpn.isConnected ? loc.t("status_connected") :
                         vpn.isConnecting ? loc.t("connecting") :
                         loc.t("status_disconnected"))
                        .font(.subheadline)
                        .foregroundColor(vpn.isConnected ? .green : .secondary)
                    Spacer()
                }

                if vpn.isConnected {
                    HStack {
                        Text("↓ \(formatBytes(vpn.bytesReceived))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("↑ \(formatBytes(vpn.bytesSent))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let error = vpn.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // Connection key
            VStack(spacing: 8) {
                if showKeyInput {
                    SecureField(loc.t("enter_key"), text: $connectionKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10))
                        .help("aivpn://...")

                    HStack {
                        Toggle(loc.t("full_tunnel"), isOn: $fullTunnel)
                            .toggleStyle(.checkbox)
                            .font(.caption)
                            .help(loc.t("full_tunnel_help"))
                        Spacer()
                    }
                } else {
                    HStack {
                        Text(vpn.savedKey.isEmpty ? loc.t("no_key") : "aivpn://\(vpn.savedKey.prefix(20))...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button(loc.t("change")) {
                            withAnimation { showKeyInput = true }
                        }
                        .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // Connect / Disconnect button
            Button(action: {
                if vpn.isConnected {
                    vpn.disconnect()
                } else {
                    let key = showKeyInput ? connectionKey : vpn.savedKey
                    if key.isEmpty {
                        withAnimation { showKeyInput = true }
                    } else if !vpn.helperAvailable {
                        vpn.checkHelperAvailable()
                    } else {
                        vpn.connect(key: key, fullTunnel: fullTunnel)
                        if showKeyInput { withAnimation { showKeyInput = false } }
                    }
                }
            }) {
                HStack {
                    Spacer()
                    if vpn.isConnecting {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16, height: 16)
                        Text(loc.t("connecting"))
                    } else if vpn.isConnected {
                        Image(systemName: "stop.circle.fill")
                        Text(loc.t("disconnect"))
                    } else {
                        Image(systemName: "play.circle.fill")
                        Text(loc.t("connect"))
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(vpn.isConnected ? .red : .blue)
            .disabled(vpn.isConnecting || !vpn.helperAvailable)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            // Footer
            HStack {
                Text("AIVPN v0.3.0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Button(loc.t("quit")) {
                    vpn.disconnect()
                    NSApp.terminate(nil)
                }
                .font(.caption2)
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 340)
        .onReceive(vpn.$isConnected) { connected in
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.updateStatusIcon(connected: connected)
            }
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024.0) }
        if bytes < 1024 * 1024 * 1024 { return String(format: "%.1f MB", Double(bytes) / 1024.0 / 1024.0) }
        return String(format: "%.1f GB", Double(bytes) / 1024.0 / 1024.0 / 1024.0)
    }
}
