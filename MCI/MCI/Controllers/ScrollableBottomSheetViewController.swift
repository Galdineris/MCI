//
//  ScrollableBottomSheetViewController.swift
//  MCI
//
//  Created by Rafael Galdino on 19/07/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import UIKit

class ScrollableBottomSheetViewController: UIViewController{
    
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = SearchViewController(searchResultsController: nil)
    
    let fullView: CGFloat = 100
    var partialView: CGFloat{
        guard let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {return 0}
        return UIScreen.main.bounds.height - (55 + safeAreaBottom)
    }
    var keyboardHeight: CGFloat = 200
    
    var filteredItens: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpSearchController()
        definesPresentationContext = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(ScrollableBottomSheetViewController.panGesture))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closeSheet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
    
    
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredItens = ["1" , "Written in diary form, it tells the tale of an unhappy, passionate young man hopelessly in love with Charlotte, the wife of a friend - a man who he alternately admires and detests." , "3" , "Maria"]//candies.filter({( candy : Candy) -> Bool in
//            return candy.name.lowercased().contains(searchText.lowercased())
//        })

        tableView.reloadData()
    }
    
    
    
    
    
    
    @IBAction func addButtonTap(_ sender: Any) {
        let novoItem:String = "not yet"//getSearchString()
        print("\(novoItem) Adicionado a sua lista")
        
        }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if !searchController.isActive{
            let translation = recognizer.translation(in: self.view)
            let velocity = recognizer.velocity(in: self.view)
            
            let y = self.view.frame.minY
            if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
                self.view.frame = CGRect(x: 0,
                                         y: y + translation.y,
                                         width: view.frame.width,
                                         height: view.frame.height)
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            
            if recognizer.state == .ended{
                var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
                
                duration = duration > 1.3 ? 1 : duration
                
                UIView.animate(withDuration: duration,
                               delay: 0.0,
                               options: [.allowUserInteraction],
                               animations: {
                                if  velocity.y >= 0 {
                                    self.view.frame = CGRect(x: 0,
                                                             y: self.partialView,
                                                             width: self.view.frame.width,
                                                             height: self.view.frame.height)
                                } else {
                                    self.view.frame = CGRect(x: 0,
                                                             y: self.fullView,
                                                             width: self.view.frame.width,
                                                             height: self.view.frame.height)
                                }
                                
                }, completion: { [weak self] _ in
                    guard let unwrapedSelf = self else {return}
                    if ( velocity.y < 0 ) {
                        unwrapedSelf.tableView.isScrollEnabled = true
                    }
                })
            }
        }
    }
    
    
    func closeSheet(){
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            guard let unwrapedSelf = self else {return}
            let frame = unwrapedSelf.view.frame
            let yComponent = unwrapedSelf.partialView
            unwrapedSelf.view.frame = CGRect(x: 0,
                                             y: yComponent,
                                             width: frame.width,
                                             height: frame.height)
            }, completion: { [weak self] _ in
                guard let unwrapedSelf = self else {return}
                unwrapedSelf.headerView.isUserInteractionEnabled = true
        })
    }
    
    func halfOpenSheet(){
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            guard let unwrapedSelf = self else {return}
            let frame = unwrapedSelf.view.frame
            let yComponent = frame.height - (unwrapedSelf.keyboardHeight + 50)
            unwrapedSelf.view.frame = CGRect(x: 0,
                                             y: yComponent,
                                             width: frame.width,
                                             height: frame.height)
            }, completion: { [weak self] _ in
                guard let unwrapedSelf = self else {return}
                unwrapedSelf.headerView.isUserInteractionEnabled = true
        })
    }
    
    
    
    
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DefaultTableViewCell", bundle: nil), forCellReuseIdentifier: "default")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    func setUpSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Busque ou Adicione um Item"
        searchController.searchBar.sizeToFit()
        searchContainer.addSubview(searchController.searchBar)
    }
    
}

    






extension ScrollableBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItens.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "default") as? DefaultTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        let Item: String
        if isFiltering() {
            Item = filteredItens[indexPath.row]
        } else {
            Item = "Written in diary form, it tells the tale of an unhappy, passionate young man hopelessly in love with Charlotte, the wife of a friend - a man who he alternately admires and detests."
        }
        
        cell.numberLabel.text = String(indexPath.row + 1)
        cell.thingLabel.text = Item
        return cell
    }
}

extension ScrollableBottomSheetViewController: UIGestureRecognizerDelegate {
    
    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        
        return false
    }
    
}

extension ScrollableBottomSheetViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if (view.frame.minY == partialView) {
            halfOpenSheet()
        }
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
}
