//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View
{
    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage

    @StateObject var availableTaps = AvailableTaps()

    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo
    
    @StateObject var updateProgressTracker = UpdateProgressTracker()

    @State private var multiSelection = Set<UUID>()

    @State private var isShowingInstallSheet: Bool = false
    @State private var isShowingTapSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none

    var body: some View
    {
        VStack
        {
            NavigationView
            {
                List(selection: $multiSelection)
                {
                    Section("Installed Formulae")
                    {
                        if !appState.isLoadingFormulae
                        {
                            ForEach(brewData.installedFormulae)
                            { package in
                                NavigationLink
                                {
                                    PackageDetailView(package: package, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: package)
                                }
                                .contextMenu
                                {
                                    Button
                                    {
                                        Task
                                        {
                                            await uninstallSelectedPackage(package: package, brewData: brewData, appState: appState)
                                        }
                                    } label: {
                                        Text("Uninstall Formula")
                                    }
                                }
                            }
                        }
                        else
                        {
                            ProgressView()
                        }
                    }
                    .collapsible(true)

                    Section("Installed Casks")
                    {
                        if !appState.isLoadingCasks
                        {
                            ForEach(brewData.installedCasks)
                            { package in
                                NavigationLink
                                {
                                    PackageDetailView(package: package, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: package)
                                }
                                .contextMenu
                                {
                                    Button
                                    {
                                        Task
                                        {
                                            await uninstallSelectedPackage(package: package, brewData: brewData, appState: appState)
                                        }
                                    } label: {
                                        Text("Uninstall Cask")
                                    }
                                }
                            }
                        }
                        else
                        {
                            ProgressView()
                        }
                    }
                    .collapsible(true)

                    Section("Tapped Taps")
                    {
                        if availableTaps.tappedTaps.count != 0
                        {
                            ForEach(availableTaps.tappedTaps)
                            { tap in
                                Text(tap.name)
                            }
                        }
                        else
                        {
                            ProgressView()
                        }
                    }
                    .collapsible(false)
                }
                .listStyle(SidebarListStyle())

                StartPage(availableTaps: availableTaps, updateProgressTracker: updateProgressTracker)
            }
            .navigationTitle("Cork")
            .navigationSubtitle("\(brewData.installedFormulae.count + brewData.installedCasks.count) packages installed")
            .toolbar
            {
                ToolbarItemGroup(placement: .primaryAction)
                {
                    Button
                    {
                        upgradeBrewPackages(updateProgressTracker)
                    } label: {
                        Label
                        {
                            Text("Upgrade Formulae")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .keyboardShortcut("r")

                    Spacer()

                    Button
                    {
                        isShowingTapSheet.toggle()
                    } label: {
                        Label
                        {
                            Text("Add Tap")
                        } icon: {
                            Image(systemName: "spigot.fill")
                        }
                    }

                    Button
                    {
                        isShowingInstallSheet.toggle()
                    } label: {
                        Label
                        {
                            Text("Add Formula")
                        } icon: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .onAppear
        {
            Task
            {
                await loadUpTappedTaps(into: availableTaps)

                brewData.installedFormulae = await loadUpFormulae(appState: appState, sortBy: sortPackagesBy)
                brewData.installedCasks = await loadUpCasks(appState: appState, sortBy: sortPackagesBy)
            }
        }
        .onChange(of: sortPackagesBy, perform: { newSortOption in
            switch newSortOption {
            case .none:
                print("Chose NONE")
                
            case .alphabetically:
                print("Chose ALPHABETICALLY")
                brewData.installedFormulae = sortPackagesAlphabetically(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesAlphabetically(brewData.installedCasks)
                
            case .byInstallDate:
                print("Chose BY INSTALL DATE")
                brewData.installedFormulae = sortPackagesByInstallDate(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesByInstallDate(brewData.installedCasks)
            }
        })
        .sheet(isPresented: $isShowingInstallSheet)
        {
            AddFormulaView(isShowingSheet: $isShowingInstallSheet)
        }
        .sheet(isPresented: $isShowingTapSheet)
        {
            AddTapView(isShowingSheet: $isShowingTapSheet, availableTaps: availableTaps)
        }
        .sheet(isPresented: $updateProgressTracker.showUpdateSheet)
        {
            VStack
            {
                ProgressView(value: updateProgressTracker.updateProgress)
                    .frame(width: 200)
                Text(updateProgressTracker.updateStage.rawValue)
            }
            .padding()
        }
        .alert(isPresented: $appState.isShowingUninstallationNotPossibleDueToDependencyAlert, content: {
            Alert(title: Text("Could Not Uninstall"), message: Text("This package is a dependency of \(appState.offendingDependencyProhibitingUninstallation)"), dismissButton: .default(Text("Close"), action: {
                appState.isShowingUninstallationNotPossibleDueToDependencyAlert = false
            }))
        })
        .environmentObject(appState)
        .environmentObject(brewData)
    }
}
