/*
    TabBarController.swift
    ShoppableApp

    Created by Cristina Dobson on 1/19/23.
 
    A TabBarController with 2 child Navigation Controllers
*/

import UIKit


class TabBarController: UITabBarController {

  //MARK: - Properties
  
  //UserDefaults
  let itemsInShoppingCartArrayKey = "itemsInShoppingCartArray"
  
  //Tab Bar
  var currentTabIndex = 0
  
  //JSON Loader
  var jsonLoader: JsonLoader?
  
  //Products 
  var productCollections: [ProductDictionary] = []
  
  //ShoppingCart
  var itemsInShoppingCartIDs: [ProductDictionary] = []
  var itemsInShoppingCartCount = 0
  var shoppingCartInfoClass: ShoppingCartInfo?
  
  //Product Information Class
  var productInfoClass: ProductInformation?
  
  
  //MARK: - View Controller's Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //TabBar's Delegate
    delegate = self
    
    //Load JSON Data
    jsonLoader = JsonLoader()
    let products = jsonLoader!.returnProductCollectionTypeArray(from: "products")
    productCollections = products
    
    //Setup the TabBar items title and style
    let tabBarItems = tabBar.items
    tabBarItems?[0].title = NSLocalizedString("Collections",
                                              comment: "Collections TabBar item title")
    tabBarItems?[1].title = NSLocalizedString("Cart",
                                              comment: "Cart TabBar item title")
    tabBar.tintColor = .label
    tabBar.unselectedItemTintColor = .systemGray3
    
    //Add a custom view to the TabBar
    let tabBarView = UIView(frame: CGRect(x: -10, y: 0,
                                          width: tabBar.frame.width+20,
                                          height: tabBar.frame.height*2))
    tabBarView.backgroundColor = UIColor.dynamicColor(light: .white, dark: .black)
    tabBarView.addBorderStyle(
      borderWidth: 0.5,
      borderColor: UIColor.dynamicColor(light: .imageBorderGray, dark: .white)
    )
    tabBar.insertSubview(tabBarView, at: 0)
        
    //Shopping Cart Information class
    shoppingCartInfoClass = ShoppingCartInfo()
    
    //Product Information Class
    productInfoClass = ProductInformation()
    
    //Get itemsInShoppingCart array from UserDefaults if it exists
    if let itemsInShoppingCartArray = UserDefaults.standard.array(forKey: itemsInShoppingCartArrayKey) as? [ProductDictionary] {
      itemsInShoppingCartIDs = itemsInShoppingCartArray
    }

    //Become the delegate of children's top controllers
    //ProductOverviewViewController delegate
    if
      let navController = getChildNavigationController(with: 0),
      let rootController = navController.topViewController as? ProductOverviewViewController
    {
      navController.navigationBar.prefersLargeTitles = true
      rootController.productOverviewViewControllerDelegate = self
      rootController.productCollections = productCollections
      rootController.itemsInShoppingCartIDs = itemsInShoppingCartIDs
    }
    
    //CartViewController delegate
    if
      let navController = getChildNavigationController(with: 1),
      let rootController = navController.topViewController as? CartViewController
    {
      rootController.cartViewControllerDelegate = self
      rootController.itemsInShoppingCartIDs = itemsInShoppingCartIDs
      rootController.productCollections = productCollections
    }
    
    //Set up the Cart TabBar item badge
    let itemsInCartCount = getItemsInShoppingCartCount(from: itemsInShoppingCartIDs)
    itemsInShoppingCartCount = itemsInCartCount
    setupCartTabBarItemBadge(with: itemsInCartCount)
  }
  
  //Get a child NavigationController
  func getChildNavigationController(with index: Int) -> UINavigationController? {
    if let navController = children[index] as? UINavigationController {
      return navController
    }
    return nil
  }
   
  //MARK: Setup Methods
  //Get the count of the products in the Shopping Cart
  func getItemsInShoppingCartCount(from array: [ProductDictionary]) -> Int {
    var itemCount = 0
    for item in array {
      if let itemsInShoppingCartCount = item[UserDefaultsKeys.inShoppingCartCount.rawValue] as? Int {
        itemCount += itemsInShoppingCartCount
      }
    }
    return itemCount
  }
}

//MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    
    let selectedTabIndex = tabBarController.selectedIndex
    
    if selectedTabIndex != currentTabIndex {
      currentTabIndex = selectedTabIndex
      let navController = viewController as! UINavigationController
      let viewController = navController.topViewController
      
      //Update data in a tapped tabBar View Controller
      switch selectedTabIndex {
        case let x where x == 0:
          if let currentController = viewController as? ProductOverviewViewController {
            currentController.itemsInShoppingCartIDs = itemsInShoppingCartIDs
          }
        case let x where x == 1:
          if let currentController = viewController as? CartViewController {
            currentController.itemsInShoppingCartIDs = itemsInShoppingCartIDs
          }
        default:
          print("Not a TabItem!")
      }
    }
  }
  
  /*
   Set the Shopping Cart's tabBar item badge if the customer
   has products on their Shopping Cart.
   
   The color of the badge will remain its default RED color
   to give the customer a sense of urgency to go to the
   Shopping Cart and buy.
   */
  func setupCartTabBarItemBadge(with count: Int) {
    let cartTabItem = tabBar.items?.last
    if count > 0 {
      cartTabItem?.badgeValue = "\(count)"
    }
    else {
      cartTabItem?.badgeValue = nil
    }
  }
}

//MARK: - ProductOverviewViewControllerDelegate
extension TabBarController: ProductOverviewViewControllerDelegate {
  
  /*
   The user has added new items to the Shopping Cart from
   ProductCatalogViewController or ProductPageViewController
   */
  func updateCartControllerFromProductCatalogController(with product: ProductDictionary) {

    //Store the IDs of the products in the Shopping Cart in UserDefaults
    if let productID = product[ProductDataKeys.id.rawValue] as? String {
      
      var itemIsInShoppingCart = false
      
      /*
       Loop throught the local variable array itemsInShoppingCartIDs
       to check if the item is already in the Shopping Cart
       */
      for i in 0..<itemsInShoppingCartIDs.count {
        
        let item = itemsInShoppingCartIDs[i]
        if
          let itemID = item[ProductDataKeys.id.rawValue] as? String,
          itemID == productID
        {
          itemIsInShoppingCart = true
          
          /*
           Update the local variable array itemsInShoppingCartIDs
            with the new count of the product
          */
          if let inShoppingCartCount = item[UserDefaultsKeys.inShoppingCartCount.rawValue] as? Int {
            let updatedCount = inShoppingCartCount + 1
            itemsInShoppingCartIDs[i].updateValue(
              updatedCount as AnyObject,
              forKey: UserDefaultsKeys.inShoppingCartCount.rawValue
            )
            
            UserDefaults.standard.set(
              itemsInShoppingCartIDs,
              forKey: itemsInShoppingCartArrayKey
            )
          }
          
          break
        }
      }
      
      /*
       If the product is not in the Shopping Cart already,
       then append it as a new item to the local array itemsInShoppingCartIDs,
       and save it to UserDeafults as well
       */
      if
        !itemIsInShoppingCart,
        let productType = product[ProductDataKeys.type.rawValue] as? String
      {
        
        let productIdDictionary: ProductDictionary = [
          UserDefaultsKeys.id.rawValue:productID as AnyObject,
          UserDefaultsKeys.productCollectionType.rawValue:productType as AnyObject,
          UserDefaultsKeys.inShoppingCartCount.rawValue:1 as AnyObject
        ]
        itemsInShoppingCartIDs.append(productIdDictionary)
        
        UserDefaults.standard.set(
          itemsInShoppingCartIDs,
          forKey: itemsInShoppingCartArrayKey
        )
      }
      
      //Update the Cart TabBar item's badge
      itemsInShoppingCartCount += 1
      setupCartTabBarItemBadge(with: itemsInShoppingCartCount)
    }
    
    //Update the total price in Shopping Cart in UserDefaults
    let price = productInfoClass?.getProductPrice(from: product)
    shoppingCartInfoClass?.updateTheShoppingCartTotal(with: price!)
  }
}

//MARK: - CartViewControllerDelegate
extension TabBarController: CartViewControllerDelegate {
  
  //The user removed a product from the shopping cart with count > 0
  func didTapRemoveItemFromCartController(_ count: Int, from index: Int) {
    itemsInShoppingCartIDs.remove(at: index)
    itemsInShoppingCartCount -= count
    setupCartTabBarItemBadge(with: itemsInShoppingCartCount)
  }
  
  //The user changed the quantity of a product in the Shopping Cart by >= 1
  func didUpdateItemQuantityFromCartController(_ count: Int, with updatedArray: [ProductDictionary]) {
    itemsInShoppingCartCount += count
    itemsInShoppingCartIDs = updatedArray
    setupCartTabBarItemBadge(with: itemsInShoppingCartCount)
  }
  
  /*
   Update the itemsInShoppingCartIDs array in CartViewController,
   when the user adds a new product to Shopping Cart from
   ProductCatalogViewController and ProductPageViewController
   */
  func updateItemsInShoppingCartIDs(on viewController: CartViewController) {
    viewController.itemsInShoppingCartIDs = itemsInShoppingCartIDs
  }
}



