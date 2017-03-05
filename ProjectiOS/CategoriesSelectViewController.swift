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
    @IBOutlet weak var selectedCategoryTagListView: TagListView!
    
    
    @IBAction func cancelSelectingCategories(_ sender: Any) {
        delegate.sendChosenCategorys(categorys: selectedCategorys)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var categorys : [String] = []
    var selectedCategorys : [String] = []
    var delegate: CategoriesSelectViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSearchBar.delegate = self
        selectedCategoryTagListView.delegate = self
        MangaUpdatesAPI.getAllCategories(completionHandler: { result in
            if let categories = result.categoryDictionary?.keys {
                self.categorys.append(contentsOf: categories)
                self.categoriesTableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension CategoriesSelectViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categorys.removeAll()
        MangaUpdatesAPI.getCategoriesFor(categorySearchTerm: searchBar.text!, page: 1, completionHandler: { result in
            if let categorys = result.categoryDictionary?.keys {
                self.categorys.append(contentsOf: categorys)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        cell.categoryNameLabel.text = categorys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categorys[indexPath.row]
        if !selectedCategorys.contains(category) {
            selectedCategorys.append(category)
            selectedCategoryTagListView.addTag(category)
        }
    }
}

extension CategoriesSelectViewController : TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        selectedCategoryTagListView.removeTag(title)
        selectedCategorys.remove(at: selectedCategorys.index(of: title)!)
    }
}
