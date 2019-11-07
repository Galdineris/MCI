//
//  ScrollableBottomSheetViewController.swift
//  MCI
//
//  Created by Rafael Galdino on 19/07/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import UIKit
import CoreData

class ScrollableBottomSheetViewController: UIViewController{
    
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var footerButtons: [UIButton]!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var notchView: UIView!
    
    
    var searchController = UISearchController(searchResultsController: nil)
    
    let fullView: CGFloat = 100
    var partialView: CGFloat{
        guard let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {return 0}
        return UIScreen.main.bounds.height -  (searchController.searchBar.frame.height + safeAreaBottom + 10)
    }
    var halfView : CGFloat{
        return self.view.frame.height - (self.keyboardHeight + searchController.searchBar.frame.height + 10)
    }
    
    var keyboardHeight: CGFloat = 200
    var filteredItems: [Item] = []
    var selectedItems: [Item] = []{
        didSet{
            changeButtons()
        }
    }
    var items: [Item] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ModelManager.shared().addDelegate(self)
        
        notchView.layer.cornerRadius = 2.5
        
        getItems()
        setupTableView()
        setupSearchController()
        setupButtons()
        
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareBackgroundView()
        changeSheetState(SheetStates.closed)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //        retrieveData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        filteredItems = items.filter({ (item: Item) -> Bool in
            guard let itemDescription: String = item.thing else {return false}
            return itemDescription.lowercased().contains(searchText.lowercased())
        })
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
                duration = duration < 0.3 ? 0.3 : duration
                
                UIView.animate(withDuration: duration,
                               delay: 0.0,
                               options: [.allowUserInteraction, .curveEaseOut],
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
                                
                }, completion: nil)
                if ( velocity.y < 0 ) {
                    self.tableView.isScrollEnabled = true
                }
            }
        }
    }
    
    
    enum SheetStates: Int{
        case open = 0
        case halfOpen = 1
        case closed = 2
    }
    func changeSheetState(_ state: SheetStates){
        var yComponent : CGFloat = 0
        var tableViewInset : CGFloat = 0
        var animDuration : Double = 0.6
        switch state {
        case .open:
            yComponent = self.fullView
            tableViewInset = view.frame.height - fullView
        case .halfOpen:
            yComponent = halfView
            tableViewInset = view.frame.height - halfView
            animDuration = 0.0
        default:
            yComponent = self.partialView
            tableViewInset = view.frame.height - partialView
        }
        UIView.animate(withDuration: animDuration, animations: { [weak self] in
            guard let unwrapedSelf = self else {return}
            let frame = unwrapedSelf.view.frame
            unwrapedSelf.view.frame = CGRect(x: 0,
                                             y: yComponent,
                                             width: frame.width,
                                             height: frame.height)
        })
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: tableViewInset,
                                              right: 0)
    }
    
    enum ButtonStates: Int{
        case add = 1
        case remove = 0
        case update = 2
    }
    func changeButtons( on: [ButtonStates]? = nil,
                        off: [ButtonStates]? = nil){
        guard let buttons = footerButtons else {return}
        if let on = on{
            for i in on{
                buttons[i.rawValue].isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.3,
                               animations: {
                                buttons[i.rawValue].alpha = 1.0
                })
            }
        }
        if let off = off{
            for i in off{
                buttons[i.rawValue].isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.3,
                               animations: {
                                buttons[i.rawValue].alpha = 0.0
                })
            }
        }
    }
    func changeButtons(){
        changeButtons(off: [.add,.remove,.update])
        if selectedItems.count == 0{
            changeButtons(off: [.add,.update,.remove])
        }else if(selectedItems.count == 1){
            changeButtons(on: [.update, .remove],
                          off: [.add])
        }else{
            changeButtons(on: [.remove],
                          off: [.add,.update])
        }
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        guard let newItemThing = searchController.searchBar.text else {return}
        saveItem(thing: newItemThing)
        searchController.isActive = false
    }
    
    @IBAction func removeButton(_ sender: Any) {
        while !(selectedItems.isEmpty) {
            if let item = selectedItems.popLast(){
                deleteItem(target: item)
            }
        }
        searchController.isActive = false
    }
    
    @IBAction func updateButton(_ sender: Any) {
        if selectedItems.count != 1 {return}
        if let updatedItem = selectedItems.popLast(),
            let indexPath = tableView.indexPathForSelectedRow {
            searchController.isActive = false
            updateAlert(updatedItem: updatedItem)
            tableView.deselectRow(at: indexPath,
                                  animated: true)

        }
    }
    
    func updateAlert(updatedItem: Item){
        let alert = UIAlertController(title: "Atualizar Item",
                                      message: "Revise abaixo o texto do item 0\(updatedItem.index)",
            preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = updatedItem.thing
            textField.keyboardType = .asciiCapable
            textField.autocorrectionType = .default
            textField.autocapitalizationType = .sentences
//            textField.addTarget(self,
//                                action: #selector(self.alertTextFieldDidChange(_:)),
//                                for: .editingChanged)
        }
        
        let saveUpdate: (UIAlertAction) -> Void = { [weak alert] (_) in
            if let textField = alert?.textFields?[0], let textFieldText = textField.text{
                if textFieldText != updatedItem.thing{
                    self.updateItem(target: updatedItem,
                                    update: textFieldText)
                }
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: saveUpdate))
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
    
//    @objc func alertTextFieldDidChange(_ sender: UITextField) {
//        alert?.actions[0].isEnabled = sender.text!.count > 0
//    }
    
    func checkForDuplicates(_ searchText: String) -> Bool{
        for item in items{
            if (item.thing?.lowercased() == searchText.lowercased()){
                return true
            }
        }
        
        return false
    }
    
    func reSelectRows(){
        for i in selectedItems{
            if isFiltering(){
                if let pos = filteredItems.firstIndex(of: i){
                    tableView.cellForRow(at: IndexPath(row: pos, section: 1))?.isSelected = true
                }
            }else{
                if let pos = items.firstIndex(of: i){
                    tableView.cellForRow(at: IndexPath(row: pos, section: 1))?.isSelected = true
                }
            }
        }
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
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DefaultTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "default")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = 80
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
    }
    
    func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        let scb = searchController.searchBar
        scb.placeholder = "Adicione ou Busque um Item"
        scb.barStyle = .blackOpaque
        scb.tintColor = UIColor.orange
        scb.keyboardAppearance = UIKeyboardAppearance.dark
        scb.keyboardType = .asciiCapable
        scb.autocorrectionType = .default
        scb.autocapitalizationType = .sentences
        scb.enablesReturnKeyAutomatically = true
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
    
    func setupButtons(){
        for i in footerButtons{
            i.layer.cornerRadius = i.frame.height/2
            i.layer.borderColor = i.tintColor.cgColor
            i.layer.borderWidth = 2.0
            i.clipsToBounds = true
        }
        changeButtons()
    }
    
}

extension ScrollableBottomSheetViewController: DataModifiedDelegate{
    func DataModified() {
        getItems()
        tableView.reloadData()
    }
    
    func getItems() {
        items = ModelManager.shared().items
    }
    
    func saveItem(thing: String){
        let status:ModelStatus = ModelManager.shared().addItem(thing: thing)
        if !(status.successful) {
            fatalError(status.description)
        }
    }
    
    func updateItem(target: Item, update: String){
        let status:ModelStatus = ModelManager.shared().editItem(target: target, newThing: update)
        if !(status.successful) {
            fatalError(status.description)
        }
    }
    
    func deleteItem(target: Item){
        if let index = items.firstIndex(of: target){
            let status:ModelStatus = ModelManager.shared().removeItem(at: index)
            if !(status.successful) {
                fatalError(status.description)
            }
        }else{
            fatalError("Error when locating item to delete")
        }
    }
    
    func indexToString(_ item : Item?) -> String{
        let maxIndex = String(items[0].index)
        guard let item = item else {return "00"}
        var index = "\(String(item.index))"
        while index.count < maxIndex.count{
            index = "0\(index)"
        }
        return "\(index)"
    }
}



//TABLEVIEW
extension ScrollableBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredItems.count
        }
        return items.count > 0 ? items.count : 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "default") as? DefaultTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        if items.isEmpty{return cell}
        
        var cellItem: Item
        
        if isFiltering() {
            cellItem = filteredItems[indexPath.row]
        } else {
            cellItem = items[indexPath.row]
        }
        
        cell.numberLabel.text = indexToString(cellItem)
        cell.thingLabel.text = cellItem.thing
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if items.isEmpty{return}
        var item: Item
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        
        if !(selectedItems.contains(item)){
            selectedItems.append(item)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
        changeButtons()
    }
    
    
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        if items.isEmpty{return}
        var item: Item
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        if let selectedIndex = selectedItems.firstIndex(of: item){
            selectedItems.remove(at: selectedIndex)
        }
        changeButtons()
    }
    
}



extension ScrollableBottomSheetViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        if !checkForDuplicates(searchString) && searchString != ""{
            changeButtons(on: [.add],
                          off: [.remove,.update])
        }else{
            changeButtons(on: [],
                          off: [.add,.remove,.update])
        }
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
