//
//  AutoDiffSearchViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 22.09.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import Changeset

struct ChangesetDiffer : EquatableDiffingAlgorithm {
    func diff<T>(from: [T], to: [T]) -> [SingleSectionOperation] where T : EntityIdentifiable, T : Equatable {
        let changeset = Changeset.edits(from: from, to: to)
        return changeset.map {
            switch $0.operation {
            case .deletion: return SingleSectionOperation.delete($0.destination)
            case .insertion: return SingleSectionOperation.insert($0.destination)
            case .substitution: return SingleSectionOperation.update($0.destination)
            case .move(origin: let offset): return SingleSectionOperation.move(from: offset, to: $0.destination)
            }
        }
    }
}

extension String: EntityIdentifiable {
    public var identifier: AnyHashable { return self }
}

class AutoDiffSearchViewController: UITableViewController, DTTableViewManageable, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)
    
    let spells = [
        "Riddikulus", "Obliviate", "Sectumsempra", "Avada Kedavra",
        "Alohomora", "Lumos", "Expelliarmus", "Wingardium Leviosa",
        "Accio", "Expecto Patronum"
    ]
    
    lazy var storage = SingleSectionEquatableStorage(items: spells, differ: ChangesetDiffer())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = DTTableViewManager(storage: storage)
        manager.register(UITableViewCell.self, for: String.self) { cell, model, _ in
            cell.textLabel?.text = model
        }
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            storage.setItems(spells)
            return
        }
        storage.setItems(spells.filter { $0.lowercased().contains(searchController.searchBar.text?.lowercased() ?? "") })
    }

}
