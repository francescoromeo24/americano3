import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    @State private var buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(LocalizedStringKey("settings_app_permissions"))){
                    NavigationLink(destination: EmptyView()) {
                        Label {
                            Text(LocalizedStringKey("settings_permissions"))
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        } icon: {
                            Image(systemName: "lock.fill")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .foregroundColor(.yellow)
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    })
                }
                
                
                Section(header: Text(LocalizedStringKey("settings_privacy_section"))) {
                    NavigationLink(destination: EmptyView()) {
                        Label {
                            Text(LocalizedStringKey("settings_privacy_policy"))
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        } icon: {
                            Image(systemName: "doc.fill")
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("settings_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel(LocalizedStringKey("settings_close"))
                    
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
