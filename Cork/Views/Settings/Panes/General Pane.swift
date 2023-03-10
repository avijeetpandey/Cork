//
//  General Pane.swift
//  Cork
//
//  Created by David Bureš on 15.02.2023.
//

import SwiftUI

struct GeneralPane: View
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none
    @AppStorage("displayAdvancedDependencies") var displayAdvancedDependencies: Bool = false
    
    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                Picker(selection: $sortPackagesBy)
                {
                    Text("Alphabetically")
                        .tag(PackageSortingOptions.alphabetically)
                    Text("By Installation Date")
                        .tag(PackageSortingOptions.byInstallDate)
                    Text("By Size")
                        .tag(PackageSortingOptions.bySize)
                    
                    Divider()
                    
                    Text("Do Not Sort")
                        .tag(PackageSortingOptions.none)
                } label: {
                    Text("Sort packages:")
                }
                
                if sortPackagesBy == .none
                {
                    Text("􀅴 Restart Cork for this sorting option to take effect")
                        .font(.caption)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }
                
                HStack(alignment: .top) {
                    Text("Dependencies:")
                    
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $displayAdvancedDependencies) {
                            Text("Show more info about dependecies")
                        }

                    }
                }
                
                Picker(selection: $caveatDisplayOptions) {
                    Text("Full display")
                        .tag(PackageCaveatDisplay.full)
                    Text("Minified display")
                        .tag(PackageCaveatDisplay.mini)
                } label: {
                    Text("Package Caveats:")
                }
                .pickerStyle(.radioGroup)
                if caveatDisplayOptions == .mini
                {
                    Text("􀅴 Click on the \"Has caveats\" pill to see the caveats")
                        .font(.caption)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }
                
                HStack(alignment: .top) {
                    Text("Search Results:")
                    
                    Toggle(isOn: $showDescriptionsInSearchResults) {
                        Text("Show descriptions in search results")
                    }
                }


            }
        }
        .frame(width: 400, height: 170, alignment: .leading)
    }
}
