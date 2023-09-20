//
//  ViewController.swift
//  Albums
//
//  Created by Anton Selivonchyk on 19/09/2023.
//

import UIKit
import Combine

class AlbumsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    private var cancellables: Set<AnyCancellable> = []
    private var viewModel = AlbumsViewModel(searchText: Settings.defaultSearchTerm.rawValue,
                                            dataProvider: DataProvider(urlString: Settings.searchURL.rawValue))

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        searchDefaultTerm()
    }

    @IBAction func errorButtonAction(_ sender: UIButton) {
        searchDefaultTerm()
    }

    // MARK: Private interface
    private func setupBindings() {
        Publishers.CombineLatest(viewModel.$albums, viewModel.$error)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] albums, error in
                    self?.reload()
                    if let error = error {
                        self?.tableView.alpha = 0.0
                        self?.errorLabel.text = error.localizedDescription
                    } else {
                        self?.tableView.alpha = 1.0
                    }
                }
                .store(in: &cancellables)
    }

    private func reload() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

    private func searchDefaultTerm() {
        viewModel.setSearchTerm(Settings.defaultSearchTerm.rawValue)
    }
}

extension AlbumsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: AlbumViewCell.self), for: indexPath) as? AlbumViewCell else {
            return UITableViewCell()
        }

        let album = viewModel.albums[indexPath.row]
        cell.titleLabel.text = album.artistName
        cell.subtitleLabel.text = album.collectionName
        return cell
    }
}

extension AlbumsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setSearchTerm(searchBar.text ?? "")
    }
}
