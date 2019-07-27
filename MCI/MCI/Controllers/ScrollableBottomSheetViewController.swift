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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var footerButtons: [UIButton]!
    
    @IBOutlet weak var tableFooterView: UIView!
    
    var searchController = UISearchController(searchResultsController: nil)
    let fullView: CGFloat = 100
    var partialView: CGFloat{
        guard let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {return 0}
        return UIScreen.main.bounds.height -  (55 + safeAreaBottom)
    }
    var keyboardHeight: CGFloat = 200
    var filteredItens: [String] = []
    var selectedItens: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpSearchController()
        setUpButtons()
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
        changeSheetState(SheetStates.closed)
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
        
        filteredItens = ["1" , "Written in diary form, it tells the tale of an unhappy, passionate young man hopelessly in love with Charlotte, the wife of a friend - a man who he alternately admires and detests." , "3" , "Maria"]
//            dataArray.filter({ (country) -> Bool in
//            let countryText: NSString = country
//
//            return (countryText.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
//        })
        tableView.reloadData()
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
    
    
    enum SheetStates: Int{
        case open = 0
        case halfOpen = 1
        case closed = 2
    }
    func changeSheetState(_ states: SheetStates){
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            guard let unwrapedSelf = self else {return}
            let frame = unwrapedSelf.view.frame
            var yComponent: CGFloat = 0
            switch states {
            case .open:
                yComponent = unwrapedSelf.fullView
            case .halfOpen:
                yComponent = frame.height - (unwrapedSelf.keyboardHeight + 55)
            default:
                yComponent = unwrapedSelf.partialView
            }
            unwrapedSelf.view.frame = CGRect(x: 0,
                                             y: yComponent,
                                             width: frame.width,
                                             height: frame.height)
        })
    }
    
    @IBAction func addButton(_ sender: Any) {
        
    }
    
    @IBAction func removeButton(_ sender: Any) {
        
    }
    
    @IBAction func updateButton(_ sender: Any) {
        
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
        tableView.tableFooterView = tableFooterView
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = 80
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
    }
    
    func setUpSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        let scb = searchController.searchBar
        scb.barStyle = .blackOpaque
        scb.tintColor = UIColor.orange
        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.white
            if let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true

            }
        }
        scb.sizeToFit()
        searchContainer.addSubview(scb)
    }
    
    func setUpButtons(){
        for i in footerButtons{
            i.layer.cornerRadius = i.frame.height/2
            i.clipsToBounds = true
        }
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
        return 30
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DefaultTableViewCell else {return}
        let cellText = cell.thingLabel.text ?? ""
        if !selectedItens.isEmpty{
            if selectedItens.contains(cellText){
                selectedItens.remove(at: selectedItens.firstIndex(of: cellText) ?? 0)
            }else{
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        guard let indexPaths = tableView.indexPathsForSelectedRows else {return}
//        if indexPaths.isEmpty{ hideAllButtons(); return}
//        if indexPaths.count <= 1{
//            hideAllButtons()
//            showSingleSelectButtons()
//        }
    }
}



extension ScrollableBottomSheetViewController: UIGestureRecognizerDelegate {
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
        guard let searchString = searchController.searchBar.text else {return}
        filterContentForSearchText(searchString)
    }
}

extension ScrollableBottomSheetViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        changeSheetState(SheetStates.halfOpen)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
    }
}
