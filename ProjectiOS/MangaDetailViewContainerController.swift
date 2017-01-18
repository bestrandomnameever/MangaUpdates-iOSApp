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
    @IBOutlet weak var blurredImageView: UIImageView!
    
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
        blurredImageView.superview!.bringSubview(toFront: blurredImageView)
        detailsLoadingActivityIndicator.superview!.bringSubview(toFront: detailsLoadingActivityIndicator)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurredImageView.addSubview(blurEffectView)
        blurredImageView.sd_setImage(with: URL.init(string: mangaCoverUrl))
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let mangaOptional = MangaUpdatesAPI.getMangaWithId(id: self.mangaId){
                DispatchQueue.main.async {
                    self.generalViewController = {
                        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        var viewController = storyBoard.instantiateViewController(withIdentifier: "mangaDetailGeneral") as! MangaDetailGeneralViewController
                        viewController.mangaCoverUrl = self.mangaCoverUrl
                        viewController.manga = mangaOptional
                        self.add(asChildViewController: viewController)
                        return viewController
                    }()
                    self.categoriesViewController = {
                        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        var viewController = storyBoard.instantiateViewController(withIdentifier: "MangaDetailRecommendations") as! MangaDetailRecommendationsViewController
                        viewController.mangaCoverUrl = self.mangaCoverUrl
                        viewController.manga = mangaOptional
                        self.add(asChildViewController: viewController)
                        return viewController
                    }()
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
        segments.insertSegment(withTitle: "Summary", at: 0, animated: false)
        segments.insertSegment(withTitle: "Recommendations", at: 1, animated: false)
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
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController){
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

}
