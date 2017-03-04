//
//  CategoriesSelectViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 04/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class CategoriesSelectViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var uiSearchBar: UISearchBar!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var selectedCategoriesTableView: UITableView!
    @IBAction func cancelSelectingCategories(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var categorys : [String] = []
    var selectedCategorys : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSearchBar.delegate = self
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
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case categoriesTableView:
            return categorys.count
        case selectedCategoriesTableView:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoriesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
            cell.categoryNameLabel.text = categorys[indexPath.row]
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
            return cell
        }
    }

}
