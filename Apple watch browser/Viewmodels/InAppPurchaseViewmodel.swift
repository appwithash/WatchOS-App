//
//  InAppPurchaseViewmodel.swift
//  Apple watch browser
//
//  Created by ashutosh on 31/01/22.
//

import SwiftUI
import StoreKit
import Combine
class InAppPurchaseViewModel : NSObject,ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    @AppStorage("is_user_subscribed") var isUserSubscribed = false
    @Published var selectSubscription = Subscription.monthly
    @Published var myProduct : SKProduct?
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    @AppStorage("is_monthly_purchased") var isMonthlyPurchased = false
    @AppStorage("is_onetime_purchased") var isOneTimePurchased = false
    var request: SKProductsRequest!
    static let shared = InAppPurchaseViewModel()
  @Published var showInAppPurchaseView = false
    @Published var showLoader = false
    
    func fetchProducts(){
       
        let request = SKProductsRequest(productIdentifiers: ["one_time_purchase","monthly_subscription"])
        print("request",request)
        request.delegate=self
        request.start()
    }
    
    func onMakePaymentTapped(){
        print("button tapped")
        self.showLoader=true
        guard let myProduct = myProduct else {
            return
        }
      
        if SKPaymentQueue.canMakePayments(){
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }else {
            print("User can't make payment.")
        }

    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
     

        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                    print(fetchedProduct.price)
                }
            }
            DispatchQueue.main.async {
            self.myProduct = self.myProducts.first
            }
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    //payemnt functions
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
                switch transaction.transactionState {
                case .purchasing:
                    print("purchasing...")
                    transactionState = .purchasing
                case .purchased:
//                    #if purchase is done
                    print("purchase successfull")
                    if self.selectSubscription == .monthly{
                        self.isMonthlyPurchased=true
                        print("purchase successfull monthly subscription")
                    }else{
                        self.isOneTimePurchased=true
                        print("purchase successfull onetime subscription")
                    }
                    self.showLoader=false
                    self.showInAppPurchaseView=false
                    queue.finishTransaction(transaction)
                    transactionState = .purchased
                case .restored:
                    print("restored")
                    
                    if self.selectSubscription == .monthly{
                        self.isMonthlyPurchased=true
                    }else{
                        self.isOneTimePurchased=true
                    }
                    self.showLoader=false
                    self.showInAppPurchaseView=false
                    queue.finishTransaction(transaction)
                    transactionState = .restored
                case .failed, .deferred:
                    print("Payment Queue Error: \(String(describing: transaction.error))")
                    
                    if self.selectSubscription == .monthly{
                        self.isMonthlyPurchased=false
                    }else{
                        self.isOneTimePurchased=false
                    }
                    self.showLoader=false
                        queue.finishTransaction(transaction)
                        transactionState = .failed
                     default:
                    self.showLoader=false
                    queue.finishTransaction(transaction)
                }
            }
    }
    
    //restore purchase
    func restoreProducts() {
        print("Restoring products ...")
        self.showLoader=true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
enum Subscription{
    case monthly, oneTime
}


