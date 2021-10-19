//
//  TitlebarAccessory.swift
//  AppStoreify
//
//  Created by Hzc on 10/18/21.
//  Copyright © 2021 seedgou. All rights reserved.
//

import SwiftUI


struct ProgressIndicator: NSViewRepresentable {
    var style: NSProgressIndicator.Style
    var controlSize: NSControl.ControlSize
    
    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let result = NSProgressIndicator()
        result.isIndeterminate = true
        result.startAnimation(nil)
        return result
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
        nsView.style = style
        nsView.controlSize = controlSize
    }
}

struct CountryCodeSelectionSheetView: View {
    @Binding var isVisible: Bool
    @ObservedObject var apps: LocalApps
    @State private var selectedCountry: String
    
    init(isVisible: Binding<Bool>, apps: LocalApps) {
        self._isVisible = isVisible
        self.apps = apps
        self._selectedCountry = State(initialValue: apps.country)
    }
    
    
    var body: some View {
        VStack {
            Picker("App Store\nCountry Code", selection: $selectedCountry) {
                ForEach(AVAILABLE_COUNTRY_CODE, id: \.self) { countryCode in
                    Text(countryCode)
                }
            }
            Button("OK") {
                self.isVisible = false
                apps.setCountryCode(country: selectedCountry)
            }
        }
        .frame(width: 300, height: 100)
        .padding()
    }
}

struct TitlebarAccessory: View {
    @ObservedObject var apps: LocalApps
    @State private var sheetIsShowing: Bool = false

    var body: some View {
        HStack(alignment: .bottom) {
            Group {
                if apps.fullLoaded{
                    if apps.matched_apps.count == 0 {
                        Image(nsImage: NSImage(named: NSImage.statusUnavailableName)!)
                        Text("Found \(apps.matched_apps.count) App")
                    }
                    else if apps.matched_apps.count == 1 {
                        Image(nsImage: NSImage(named: NSImage.statusAvailableName)!)
                        Text("Found \(apps.matched_apps.count) App")
                    }
                    else {
                        Image(nsImage: NSImage(named: NSImage.statusAvailableName)!)
                        Text("Found \(apps.matched_apps.count) Apps")
                    }
                }
                else{
                    ProgressIndicator(style: .spinning, controlSize: .small)
                    Text("Loading: \(apps.ready_apps_count)/\(apps.apps_count)")
                }
            }
            HStack {
                Button(action: {
                    self.apps.refresh()
                }) {
                    Image(nsImage: NSImage(named: NSImage.refreshTemplateName)!)
                }.buttonStyle(BorderlessButtonStyle())
                Button(action: {
                    self.sheetIsShowing = true
                }) {
                    Image(nsImage: NSImage(named: NSImage.actionTemplateName)!)
                }.buttonStyle(BorderlessButtonStyle())
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], 16.0)
        .padding([.top, .bottom], 12.0)
        .sheet(isPresented: $sheetIsShowing) {
            CountryCodeSelectionSheetView(isVisible: $sheetIsShowing, apps: apps)
        }
    }
}

struct TitlebarAccessory_Previews: PreviewProvider {
    static var previews: some View {
        TitlebarAccessory(apps: LocalApps.shared)
    }
}
