//
//  Settings View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct SettingsView: View
{
    var body: some View
    {
        TabView
        {
            GeneralPane()
                .tabItem
                {
                    Label("General", systemImage: "gearshape")
                }

            MaintenancePane()
                .tabItem
                {
                    Label("Maintenance", systemImage: "arrow.3.trianglepath")
                }

            BrewPane()
                .tabItem {
                    Label("Homebrew", systemImage: "cup.and.saucer")
                }
            /*InstallationAndUninstallationPane()
                .tabItem
                {
                    Label("Install and Uninstall", systemImage: "plus")
                }*/
        }
    }
}
