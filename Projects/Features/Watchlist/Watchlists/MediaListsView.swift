//
//  MediaListsView.swift
//  Watchlist
//
//  Created by Sergii Shulga on 14/01/2025.
//

import SwiftUI

public struct MediaListsView: View {
    @State
    private var selection: Selection = .movies
    
    let moviesViewModel: MoviesListsViewModel
    let animeViewModel: AnimeListsViewModel
    
    public init(moviesViewModel: MoviesListsViewModel, animeViewModel: AnimeListsViewModel) {
        self.moviesViewModel = moviesViewModel
        self.animeViewModel = animeViewModel
    }
    
    public var body: some View {
//        TabView(selection: $selection) { // For some reason TabView does not work when navigating back from a navigation controller
        HorizontalPageView(
            selection: selection,
            moviesView: {
                MoviesListsView(viewModel: moviesViewModel)
            },
            animeView: {
                AnimeListsView(viewModel: animeViewModel)
            }
        )
//        .tabViewStyle(.page)
        .navigationTitle(selection == .movies ? "My Movies" : "My Anime")
        .toolbar(content: {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker(selection: $selection.animation(), label: Text("")) {
                    Image(systemName: "film")
                        .tag(Selection.movies)
            
                    Image(systemName: "sparkles")
                        .tag(Selection.anime)
                }
                .pickerStyle(.inline)
            }
        })
    }
    
    enum Selection {
        case movies
        case anime
    }
}

import UIKit

struct HorizontalPageView: UIViewControllerRepresentable {
    var selection: MediaListsView.Selection
    var moviesView: () -> MoviesListsView
    var animeView: () -> AnimeListsView
    
    init(
        selection: MediaListsView.Selection,
        moviesView: @escaping () -> MoviesListsView,
        animeView: @escaping () -> AnimeListsView
    ) {
        self.selection = selection
        self.moviesView = moviesView
        self.animeView = animeView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            firstVC: UIHostingController(rootView: moviesView()),
            secondVC: UIHostingController(rootView: animeView())
        )
    }
        
    func makeUIViewController(context: Context) -> UIPageViewController {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        switch selection {
        case .movies:
            viewController.setViewControllers(
                [context.coordinator.firstVC],
                direction: .reverse,
                animated: false
            )
        case .anime:
            viewController.setViewControllers(
                [context.coordinator.secondVC],
                direction: .forward,
                animated: false
            )
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        switch selection {
        case .movies:
            uiViewController.setViewControllers(
                [context.coordinator.firstVC],
                direction: .reverse,
                animated: true
            )
        case .anime:
            uiViewController.setViewControllers(
                [context.coordinator.secondVC],
                direction: .forward,
                animated: true
            )
        }
        uiViewController.delegate = context.coordinator
        uiViewController.dataSource = context.coordinator
    }
    
    final class Coordinator: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
        let firstVC: UIViewController
        let secondVC: UIViewController
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            if viewController === firstVC {
                return nil
            }
            return firstVC
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            if viewController === secondVC {
                return nil
            }
            return secondVC
        }
        
        init(firstVC: UIViewController, secondVC: UIViewController) {
            self.firstVC = firstVC
            self.secondVC = secondVC
            super.init()
        }
    }
}
