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
    var filteredItems: [Item] = []
    var selectedItems: [Item] = []
    var items: [Item] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpSearchController()
        setUpButtons()
        changeButtons([], [.add,.remove,.update])
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
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Item")
        
        do {
            items = try managedContext.fetch(fetchRequest) as! [Item]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
    func changeSheetState(_ state: SheetStates){
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            guard let unwrapedSelf = self else {return}
            let frame = unwrapedSelf.view.frame
            var yComponent: CGFloat = 0
            switch state {
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
    
    enum ButtonStates: Int{
        case add = 1
        case remove = 0
        case update = 2
    }
    func changeButtons(_ on: [ButtonStates]?, _ off: [ButtonStates]?){
        guard let buttons = footerButtons else {return}
        if let on = on{
            for i in on{
                buttons[i.rawValue].isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                    buttons[i.rawValue].alpha = 1.0
                })
            }
        }
        if let off = off{
            for i in off{
                UIView.animate(withDuration: 0.5,
                               animations: {
                    buttons[i.rawValue].alpha = 0.0
                    },
                               completion: { (true) in
                        buttons[i.rawValue].isHidden = true
                })
            }
        }
    }

    
    @IBAction func addButton(_ sender: Any) {
        guard let newItemDescription = searchController.searchBar.text else {return}
        saveItem(description: newItemDescription)
        tableView.reloadData()
        changeButtons([], [.add,.remove,.update])
        searchController.isActive = false
    }
    
    @IBAction func removeButton(_ sender: Any) {
        for i in selectedItems{
            deleteItem(target: i)
        }
        tableView.reloadData()
        changeButtons([], [.add,.remove,.update])
        searchController.isActive = false
    }
    
    @IBAction func updateButton(_ sender: Any) {
        
    }
    
    func saveItem(description: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let itemEntity =
            NSEntityDescription.entity(forEntityName: "Item",
                                       in: managedContext)!
        
        let item = NSManagedObject(entity: itemEntity,
                                     insertInto: managedContext)
        
        item.setValue(description, forKeyPath: "thing")
        
        do {
            try managedContext.save()
            items.append(item as! Item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "index", ascending: false)]
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                items.append(data as! Item)
            }
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateItem(thing: String, target: Item){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "index = %d", target.index)
        do
        {
            let itemToChange = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = itemToChange[0] as! NSManagedObject
            objectUpdate.setValue(thing, forKey: "thing")
            do{
                try managedContext.save()
            }
            catch let error as NSError
            {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteItem(target: Item){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "index = %d", target.index)
        do
        {
            let ItemToDelete = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = ItemToDelete[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            updateIndices()
            do{
                try managedContext.save()
            }
            catch let error as NSError
            {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateIndices(){
        
        var newIndex: Int16 = 1
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "index", ascending: false)]
        do
        {
            let itemsToChange = try managedContext.fetch(fetchRequest)
            for i in itemsToChange{
                let objectUpdate = i as! NSManagedObject
                objectUpdate.setValue(newIndex, forKey: "index")
                do{
                    try managedContext.save()
                }
                catch let error as NSError
                {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                newIndex += 1
            }
        }
        catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func checkDuplicate(text: String) -> Bool{
        for i in items{
            if ((i.thing?.compare(text)) != nil){
                return true
            }
        }
        return false
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
        retrieveData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DefaultTableViewCell", bundle: nil), forCellReuseIdentifier: "default")
        tableView.tableFooterView = self.tableFooterView
        
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
            return filteredItems.count
        }
        return items.count > 0 ? items.count : 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 44
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "default") as? DefaultTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        if items.isEmpty{
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        var item: Item
        
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        
        cell.numberLabel.text = String(item.index)
        cell.thingLabel.text = item.thing
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item: Item
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        if selectedItems.isEmpty || !selectedItems.contains(item){
            selectedItems.append(item)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
        switch selectedItems.count {
        case 0:
            changeButtons([], [.add,.update,.remove])
        default:
            changeButtons([.remove], [.add,.update])
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var item: Item
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        if let selectedIndex = selectedItems.firstIndex(of: item){
            selectedItems.remove(at: selectedIndex)
        }
        switch selectedItems.count {
        case 0:
            changeButtons([], [.add,.remove,.update])
        case 1:
            changeButtons([.remove, .update], [.add])
        default:
            changeButtons([.remove], [.update,.add])
        }
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
        if checkDuplicate(text:( searchController.searchBar.text ?? "")) {
            changeButtons([.add], [.remove,.update])
        }else{
            changeButtons([], [.add,.remove,.update])
        }
    }
}
