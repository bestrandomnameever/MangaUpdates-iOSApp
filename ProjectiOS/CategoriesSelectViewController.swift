//
//  CategoriesSelectViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 04/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit
import TagListView

protocol CategoriesSelectViewControllerDelegate {
    func sendChosenCategorys(categorys: [String])
}

class CategoriesSelectViewController: UIViewController {
    
    @IBOutlet weak var uiSearchBar: UISearchBar!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var tagListView: TagListView!
    
    
    
    @IBAction func cancelSelectingCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func applySelectedCategories(_ sender: Any) {
        delegate.sendChosenCategorys(categorys: selectedCategorys)
        self.navigationController?.popViewController(animated: false)
    }
    
    var categorys : [String] = []
    var selectedCategorys : [String] = []
    var delegate: CategoriesSelectViewControllerDelegate!
    var currentCategoryResult: CategorySearchResult? = nil
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSearchBar.delegate = self
        tagListView.delegate = self
        MangaUpdatesAPI.getAllCategories(completionHandler: { result in
            if let categories = result.categoryDictionary?.keys.sorted() {
                self.categorys.append(contentsOf: categories)
                self.currentCategoryResult = result
                self.categoriesTableView.reloadData()
            }
        })
        for category in selectedCategorys {
            tagListView.addTag(category)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "searchWithCategory":
            let destination = segue.destination as! MangaSearchResultsViewController
            let button = sender as! UIButton
            let category = (button.superview!.superview! as! CategoryCell).categoryNameLabel.text!
            destination.originalSearchUrl = MangaUpdatesURLBuilder.init().withCategories([category]).getUrl()
            break
        default:
            break
        }
    }
    
    
    
    
}

extension CategoriesSelectViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categorys.removeAll()
        currentCategoryResult = nil
        self.categoriesTableView.reloadData()
        MangaUpdatesAPI.getCategoriesFor(categorySearchTerm: searchBar.text!, page: 1, completionHandler: { result in
            if let categorys = result.categoryDictionary?.keys.sorted() {
                self.categorys.append(contentsOf: categorys)
                self.currentCategoryResult = result
                self.categoriesTableView.reloadData()
            }
        })
        self.view.endEditing(true)
    }
}

extension CategoriesSelectViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == categorys.count - 20 {
            if let current = currentCategoryResult {
                if current.hasNextPage {
                    MangaUpdatesAPI.getCategoriesFor(categorySearchTerm: uiSearchBar.text!, page: current.currentPage+1, completionHandler: { result in
                        if let categories = result.categoryDictionary?.keys.sorted() {
                            self.categorys.append(contentsOf: categories)
                            self.currentCategoryResult = result
                            self.categoriesTableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentCategoryResult != nil {
            if currentCategoryResult!.hasNextPage {
                return categorys.count + 1
            }else {
                return categorys.count
            }
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == categorys.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categorysLoadingCell", for: indexPath) as! CategorysLoadingCell
            cell.categorysLoadingIndicator.startAnimating()
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
            cell.categoryNameLabel.text = categorys[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != categorys.count {
            let category = categorys[indexPath.row]
            if !selectedCategorys.contains(category) {
                selectedCategorys.append(category)
                tagListView.addTag(category)
            }
        }
    }
}

extension CategoriesSelectViewController : TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagListView.removeTag(title)
        selectedCategorys.remove(at: selectedCategorys.index(of: title)!)
    }
}
