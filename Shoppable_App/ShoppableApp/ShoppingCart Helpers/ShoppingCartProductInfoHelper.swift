//
//  ShoppingCartProductInfoHelper.swift
//  ShoppableApp
//
//  Created on 2/8/23.
//


import Foundation


// MARK: - Shopping Cart Keys enum

/*
 Keys used to store in UserDefaults the IDs of the products
 in the Shopping Cart
 */
enum UserDefaultsKeys: String {
  case id
  case inShoppingCartCount
  case type
}


struct ShoppingCartProductInfoHelper {
  
  // MARK: - Item ID
  
  // Get the Shopping Cart item ID
  static func getShoppingCartItemID(from product: ProductDictionary) -> String {
    
    if let id = product[UserDefaultsKeys.id.rawValue] as? String {
      return id
    }
    return ""
  }
  
  
  // MARK: - Item Type
  
  // Get the Shopping Cart item type
  static func getShoppingCartItemType(from product: ProductDictionary) -> String {
    
    if let type = product[UserDefaultsKeys.type.rawValue] as? String {
      return type
    }
    return ""
  }
  
  // MARK: - Single Item Count in Shopping Cart 
  
  // Get the product count in the Shopping Cart
  static func getSingleProductCountInShoppingCart(from currentProduct: ProductDictionary) -> Int {
    
    if let productCount = currentProduct[UserDefaultsKeys.inShoppingCartCount.rawValue] as? Int {
      return productCount
    }
    return 0
  }

}
















