//
//  Tap Details.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

class SelectedTapInfo: ObservableObject
{
    @Published var contents: String = .init()
}

struct TapDetailView: View
{
    @State var tap: BrewTap
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: AvailableTaps

    @StateObject var selectedTapInfo: SelectedTapInfo

    @State private var isLoadingTapInfo: Bool = true

    @State private var homepage: URL = .init(string: "https://google.com")!
    @State private var isOfficial: Bool = false
    @State private var includedFormulae: [String]?
    @State private var includedCasks: [String]?
    @State private var numberOfPackages: Int = 0

    @State private var isShowingIncludedFormulae: Bool = false
    @State private var isShowingIncludedCasks: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .center, spacing: 5)
                {
                    Text(tap.name)
                        .font(.title)

                    if isOfficial
                    {
                        Image(systemName: "checkmark.shield")
                            .help("\(tap.name) an official tap.\nPackages included in it are audited to make sure they are safe.")
                    }
                }
            }

            if isLoadingTapInfo
            {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        ProgressView {
                            Text("Loading tap info...")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            else
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("Info")
                        .font(.title2)

                    GroupBox
                    {
                        Grid(alignment: .leading)
                        {
                            GridRow(alignment: .firstTextBaseline) {
                                Text("Contents")
                                
                                if includedFormulae == nil && includedCasks == nil
                                {
                                    Text("None")
                                }
                                else if includedFormulae != nil && includedCasks == nil
                                {
                                    Text("Only Formulae")
                                }
                                else if includedCasks != nil && includedFormulae == nil
                                {
                                    Text("Only Casks")
                                }
                                else if includedFormulae?.count ?? 0 > includedCasks?.count ?? 0
                                {
                                    Text("Mostly Formulae")
                                }
                                else if includedFormulae?.count ?? 0 < includedCasks?.count ?? 0
                                {
                                    Text("Mostly Casks")
                                }
                            }
                            
                            Divider()
                            
                            GridRow(alignment: .firstTextBaseline) {
                                Text("Number of Packages")
                                Text(String(numberOfPackages))
                            }
                            
                            Divider()
                            
                            GridRow(alignment: .firstTextBaseline)
                            {
                                Text("Homepage")
                                Link(destination: homepage)
                                {
                                    Text(homepage.absoluteString)
                                }
                            }
                        }
                    }

                    if includedFormulae != nil || includedCasks != nil
                    {
                        GroupBox
                        {
                            VStack
                            {
                                if let includedFormulae
                                {
                                    DisclosureGroup("Formulae Included", isExpanded: $isShowingIncludedFormulae)
                                    {}
                                    .disclosureGroupStyle(NoPadding())
                                    if isShowingIncludedFormulae
                                    {
                                        PackagesIncludedInTapList(packages: includedFormulae)
                                    }
                                }

                                if includedFormulae != nil && includedCasks != nil
                                {
                                    Divider()
                                }
                                
                                if let includedCasks
                                {
                                    DisclosureGroup("Casks Included", isExpanded: $isShowingIncludedCasks)
                                    {}
                                    .disclosureGroupStyle(NoPadding())
                                    if isShowingIncludedCasks
                                    {
                                        PackagesIncludedInTapList(packages: includedCasks)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                    
                    HStack
                    {
                        Spacer()
                        
                        UninstallationProgressWheel()
                        
                        Button {
                            Task(priority: .userInitiated)
                            {
                                try await removeTap(name: tap.name, availableTaps: availableTaps, appState: appState)
                            }
                        } label: {
                            Text("Remove \(tap.name)")
                        }

                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear
        {
            Task(priority: .userInitiated)
            {
                async let tapInfo = await shell(AppConstants.brewExecutablePath.absoluteString, ["tap-info", "--json", tap.name]).standardOutput

                let parsedJSON = try await parseJSON(from: tapInfo)

                homepage = getTapHomepageFromJSON(json: parsedJSON)
                isOfficial = getTapOfficialStatusFromJSON(json: parsedJSON)
                includedFormulae = getFormulaeAvailableFromTap(json: parsedJSON, tap: tap)
                includedCasks = getCasksAvailableFromTap(json: parsedJSON, tap: tap)

                numberOfPackages = Int(includedFormulae?.count ?? 0) + Int(includedCasks?.count ?? 0)
                
                isLoadingTapInfo = false
            }
        }
    }
}
