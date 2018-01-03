//
//  SearchViewController.swift
//  Lush Player
//
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

import UIKit
import LushPlayerKit

/// The view controller responsible for showing LUSH search results
class SearchResultsViewController: RefreshableViewController {
    
    /// The current search term to use to search for LUSH programmes
    var searchTerm: String?
    
    /// The array of search results for the current search term
    var searchResults: [Programme]?
    
    /// A collection view used to display the search results
    @IBOutlet weak var resultsCollectionView: UICollectionView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Register the programme cell to the collection view
        let nib = UINib(nibName: "ProgrammeCollectionViewCell", bundle: nil)
        resultsCollectionView.register(nib, forCellWithReuseIdentifier: "ProgrammeCell")
        
        // Setup insets
        resultsCollectionView.contentInset = UIEdgeInsets(top: 60, left: 92, bottom: 0, right: 92)
        
        // Setup line spacing
        guard let flowLayout = resultsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumLineSpacing = 36
    }

    override func refresh(completion: (() -> Void)? = nil) {
        
        // Make sure we have a search term and it isn't empty
        guard let searchTerm = searchTerm, !searchTerm.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            
            // If it is empty or non-existent set searchResults to empty array and redraw
            searchResults = []
            redraw()
            return
        }
        
        let term = searchTerm.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Perform the actual search
        LushPlayerController.shared.performSearch(for: term, with: { [weak self] (error, results) in
        
            // If we get an error, then display it
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            // Set searchResults and redraw
            self?.searchResults = results
            self?.redraw()
        })
    }
    
    override func redraw() {
        
        resultsCollectionView.reloadData()
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Set the search term and hit the LUSH API
        searchTerm = searchController.searchBar.text
        refresh()
    }
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Hard-coded size is okay here because we're always displaying on a 1080p display
        return CGSize(width: 400, height: 420)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Make sure we have results
        guard let results = searchResults else { return }
        
        // Get selected result from array
        let result = results[indexPath.item]
        
        show(programme: result)
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let results = searchResults else { return 0 }
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a programme cell
        guard let programmeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath) as? ProgrammeCollectionViewCell, let searchResults = searchResults else {
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath)
        }
        
        let result = searchResults[indexPath.item]
        
        // Configure the programme cell's UI
        programmeCell.imageView.set(imageURL: result.thumbnailURL, withPlaceholder: nil, completion: nil)
        programmeCell.formatLabel.text = result.media.displayString()
        programmeCell.titleLabel.text = result.title
        programmeCell.dateLabel.text = ""
        
        return programmeCell
    }
}
