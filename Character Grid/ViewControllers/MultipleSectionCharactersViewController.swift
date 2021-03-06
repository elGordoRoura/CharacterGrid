//
//  MultipleSectionCharactersViewController.swift
//  Character Grid
//
//  Created by Christopher J. Roura on 11/5/20.
//

import UIKit
import SwiftUI

class MultipleSectionCharactersViewController: UIViewController {
    
    private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let segmentedControl = UISegmentedControl(
        items: Universe.allCases.map { $0.title }
    )
    
    private var sectionedCharacters = Universe.ff7r.sectionedStubs {
        didSet {
            updateCollectionView(oldSectionItems: oldValue, newSectionItems: sectionedCharacters)
        }
    }
    
    private var cellRegistration: UICollectionView.CellRegistration<CharacterCell, Character>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<HeaderView>!
    
    
    private func updateCollectionView(oldSectionItems: [SectionCharacters], newSectionItems: [SectionCharacters]) {
        var sectionsToInsert    = IndexSet()
        var sectionsToRemove    = IndexSet()
        var indexPathsToRemove  = [IndexPath]()
        var indexPathsToInsert  = [IndexPath]()
        
        let sectionDiff = newSectionItems.difference(from: oldSectionItems)
        sectionDiff.forEach { (change) in
            switch change {
                case let .remove(offset, _, _):
                    sectionsToRemove.insert(offset)
                case let .insert(offset, _, _):
                    sectionsToInsert.insert(offset)
            }
        }
        
        (0..<newSectionItems.count).forEach { (index) in
            let newSection = newSectionItems[index]
            if let oldSectionIndex = oldSectionItems.firstIndex(where: { $0 == newSection }) {
                let oldSection = oldSectionItems[oldSectionIndex]
                let diff = newSection.characters.difference(from: oldSection.characters)
                diff.forEach { (change) in
                    switch change {
                    
                    case let .remove(offset, _, _):
                            indexPathsToRemove.append(IndexPath(item: offset, section: oldSectionIndex))
        
                    case let .insert(offset, _, _):
                            indexPathsToInsert.append(IndexPath(item: offset, section: index))
                    }
                }
            }
        }
        
        
        collectionView.performBatchUpdates {
            self.collectionView.deleteSections(sectionsToRemove)
            self.collectionView.deleteItems(at: indexPathsToRemove)
            self.collectionView.insertSections(sectionsToInsert)
            self.collectionView.insertItems(at: indexPathsToInsert)
        } completion: { (_) in
            let headerIndexPaths = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headerIndexPaths.forEach { (indexPath) in
                let headerView  = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! HeaderView
                let section     = self.sectionedCharacters[indexPath.section]
                headerView.configure(text: "\(section.category) (\(section.characters.count))".uppercased())
            }
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupSegmentedControl()
        setupCollectionView()
        setupLayout()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(shuffleTapped))
    }
    
    
    @objc private func shuffleTapped() {
        self.sectionedCharacters = self.sectionedCharacters.shuffled().map {
            SectionCharacters(category: $0.category, characters: $0.characters.shuffled())
        }
    }
    
    
    private func setupSegmentedControl() {
        navigationItem.titleView                = segmentedControl
        segmentedControl.selectedSegmentIndex   = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    
    private func setupCollectionView() {
        collectionView.frame            = view.bounds
        collectionView.backgroundColor  = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.delegate         = self
        collectionView.dataSource       = self
        
        cellRegistration = UICollectionView.CellRegistration { (cell: CharacterCell, _, character: Character) in
            cell.setup(character: character)
        }
        
        headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { (header: HeaderView, _, indexPath) in
            let section = self.sectionedCharacters[indexPath.section]
            header.configure(text: "\(section.category) (\(section.characters.count))".uppercased())
        }
        view.addSubview(collectionView)
    }
    
    
    private func setupLayout() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let padding: CGFloat                = 8
        flowLayout.sectionInset             = .init(top: 0, left: padding, bottom: 0, right: padding)
        flowLayout.minimumLineSpacing       = 0
        flowLayout.minimumInteritemSpacing  = 0
        flowLayout.estimatedItemSize        = UICollectionViewFlowLayout.automaticSize
    }

    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        sectionedCharacters = sender.selectedUniverse.sectionedStubs
    }
}


extension MultipleSectionCharactersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionedCharacters.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionedCharacters[section].characters.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character   = sectionedCharacters[indexPath.section].characters[indexPath.item]
        let cell        = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: character)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        return headerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView  = HeaderView()
        let section     = sectionedCharacters[section]
        headerView.configure(text: "\(section.category) (\(section.characters.count))".uppercased())
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}


struct MultipleSectionCharactersViewControllerRepresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: MultipleSectionCharactersViewController())
    }
}


struct MultipleSectionViewController_Previews: PreviewProvider {
    static var previews: some View {
        MultipleSectionCharactersViewControllerRepresentable()
            .edgesIgnoringSafeArea(.vertical)
            .environment(\.colorScheme, ColorScheme.dark)
    }
}
