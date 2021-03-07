//
//  MainViewController.swift
//  GoldenScent
//
//  Created by Vinsi on 05/03/2021.
//

import UIKit
fileprivate extension Double {
    
    var toFloat: CGFloat {
        CGFloat(self)
    }
}

extension MainViewController.ViewModel {
    
    func createCellViewModel(section: Int) -> ContentCell.ViewModel? {
        guard let type = sectionType(section: section),
              let row = rowitem(section: section) else {
            return nil
        }
        switch type {
        case .customSlider:
            return ContentCell.ViewModel(content: .slider(data: row.columns?.first?.slides ?? []) )
        case .image,.text:
            return ContentCell.ViewModel(content: .image(column: row.columns ?? []))
        }
    }
}

final class MainViewController: UIViewController {
    private let viewModel = ViewModel()
    private var cellViewModels = [ContentCell.ViewModel]()
    @IBOutlet var collectionView: UICollectionView!
    fileprivate func setupUI() {
        cellViewModels = (0 ..< viewModel.numberOfSections).compactMap({
            self.viewModel.createCellViewModel(section: $0)
        })
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load { [weak self] in
            self?.setupUI()
        }
    }
}

extension MainViewController {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let type = self.viewModel.sectionType(section: sectionNumber)
            let row = self.viewModel.rowitem(section: sectionNumber)
            switch (type,row) {
            case (.image,.some(let row)),(.text,.some(let row)):
                return self.imageLayoutSection(row: row )
            case (.customSlider,.some(let row)):
                return self.sliderLayoutSection(row: row)
            default:
                return nil
            }
        }
    }
    
    private func sliderLayoutSection(row: LayoutDataModel.Row, spacing: CGFloat = 16.0) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(row.height?.value.toFloat ?? 100))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = spacing
        item.contentInsets.trailing = spacing
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(row.height?.value.toFloat ?? 100))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets.leading = row.rowMarginLeft?.value.toFloat ?? 0
        section.contentInsets.trailing = row.rowMarginRight?.value.toFloat ?? 0
        section.contentInsets.bottom = row.rowMarginBottom?.value.toFloat ?? 0
        
        return section
    }
    
    private func imageLayoutSection(row: LayoutDataModel.Row,spacing: CGFloat = 16) -> NSCollectionLayoutSection {
        let fullWidth = collectionView.bounds.size.width
        let count = row.columns?.count ?? 1
        let totalSpacing = spacing * CGFloat(count - 1)
        let totalMargin = (row.rowMarginLeft?.value.toFloat ?? 0) + (row.rowMarginRight?.value.toFloat ?? 0)
        let remainingWidth = fullWidth - totalMargin - totalSpacing
        let itemWidth = remainingWidth / CGFloat(count)
        let defaultHeight = row.columns?.first?.type == .some(.text) ? CGFloat(35) : CGFloat(100)
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(row.height?.value.toFloat ?? defaultHeight))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: spacing, trailing: spacing)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(row.height?.value.toFloat ?? defaultHeight))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = row.rowMarginLeft?.value.toFloat ?? 0
        section.contentInsets.trailing = row.rowMarginRight?.value.toFloat ?? 0
        section.contentInsets.bottom = row.rowMarginBottom?.value.toFloat ?? 0
        return section
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as? ContentCell,
              let cellViewModel = cellViewModels[safe: indexPath.section] else {
            return UICollectionViewCell()
        }
        cell.configure(viewModel: cellViewModel, index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        cellViewModels[indexPath.section].selectedIndex = indexPath.row
        if case .slider = cellViewModels[indexPath.section].content {
        if let prevIndex = cellViewModels[indexPath.section].previousIndex {
            let index = IndexPath(item: prevIndex, section: indexPath.section)
            collectionView.reloadItems(at: [indexPath,index])
        }
        collectionView.reloadItems(at: [indexPath])
        }
        let viewController: MainViewController = UIStoryboard(storyboard: .main).instantiateViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
