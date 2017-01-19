//
//  MangaDetailSegmentedController.swift
//  ProjectiOS
//
//  Created by Anthony on 18/01/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class MangaDetailViewContainerController: UIViewController {
    
    var mangaId : String!
    var mangaCoverUrl : String!
    
    @IBOutlet weak var detailsLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var coverBackgroundImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var subViewContainer: UIView!
    
    @IBOutlet weak var segments: UISegmentedControl!
    private var generalViewController: MangaDetailGeneralViewController!
    
    private var categoriesViewController: MangaDetailRecommendationsViewController!
    
    override func viewWillAppear(_ animated: Bool) {
        segments.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadManga()
    }
    
    func loadManga(){
        self.detailsLoadingActivityIndicator.startAnimating()
        coverBackgroundImageView.sd_setImage(with: URL.init(string: mangaCoverUrl))
        detailsLoadingActivityIndicator.superview!.bringSubview(toFront: detailsLoadingActivityIndicator)
        backgroundView.superview!.bringSubview(toFront: backgroundView)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let mangaOptional = MangaUpdatesAPI.getMangaWithId(id: self.mangaId){
                DispatchQueue.main.async {
                    self.generalViewController = {
                        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let viewController = storyBoard.instantiateViewController(withIdentifier: "mangaDetailGeneral") as! MangaDetailGeneralViewController
                        viewController.mangaCoverUrl = self.mangaCoverUrl
                        viewController.manga = mangaOptional
                        self.add(asChildViewController: viewController)
                        return viewController
                    }()
                    self.categoriesViewController = {
                        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let viewController = storyBoard.instantiateViewController(withIdentifier: "MangaDetailRecommendations") as! MangaDetailRecommendationsViewController
                        viewController.mangaCoverUrl = self.mangaCoverUrl
                        viewController.manga = mangaOptional
                        self.add(asChildViewController: viewController)
                        return viewController
                    }()
                    self.detailsLoadingActivityIndicator.stopAnimating()
                    self.setupView()
                }
            }
        }
    }
    
    func setupView(){
        setupSegmentedControl()
        updateView()
    }
    
    func setupSegmentedControl(){
        segments.removeAllSegments()
        segments.insertSegment(withTitle: "Sum", at: 0, animated: false)
        segments.insertSegment(withTitle: "Rec", at: 1, animated: false)
        segments.isHidden = false
        segments.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        segments.selectedSegmentIndex = 0
    }
    
    func selectionDidChange(_ sender: UISegmentedControl){
        updateView();
    }
    
    private func updateView(){
        if segments.selectedSegmentIndex == 0{
            remove(asChildViewController: categoriesViewController)
            add(asChildViewController: generalViewController)
        }else{
            remove(asChildViewController: generalViewController)
            add(asChildViewController: categoriesViewController)
        }
    }
    
    private func add(asChildViewController viewController: UIViewController){
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        var bounds = view.bounds
        bounds.origin.y = (navigationController?.navigationBar.frame.maxY)!
        bounds.size.height = bounds.height - bounds.origin.y
        viewController.view.frame = bounds
        viewController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController){
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

}
