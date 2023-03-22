//
//  InAppPurchaseView.swift
//  Apple watch browser
//
//  Created by ashutosh on 31/01/22.
//

import SwiftUI

struct InAppPurchaseView: View {
   
    @ObservedObject var inAppPurchaseViewModel : InAppPurchaseViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            Color("blue")
                .ignoresSafeArea()
            VStack{
                ZStack{
                    Circle()
                        .trim(from: 0.2, to: 1)
                        .stroke(Color.white.opacity(0.1))
                        .frame(width: Screen.maxWidth*0.4, height: Screen.maxWidth*0.4)
                        .rotationEffect(.degrees(55))
                    Circle()
                        .trim(from: 0.2, to: 1)
                        .stroke(Color.white.opacity(0.1))
                        .frame(width: Screen.maxWidth*0.6, height: Screen.maxWidth*0.6)
                        .rotationEffect(.degrees(55))
                    Circle()
                        .trim(from: 0.2, to: 1)
                        .stroke(Color.white.opacity(0.1))
                        .frame(width: Screen.maxWidth*0.8, height: Screen.maxWidth*0.8)
                        .rotationEffect(.degrees(55))
                    
                    Circle()
                        .trim(from: 0.2, to: 1)
                        .stroke(Color.white.opacity(0.1))
                        .frame(width: Screen.maxWidth, height: Screen.maxWidth)
                        .rotationEffect(.degrees(55))
                }
                Spacer()
            }
            .ignoresSafeArea()
            VStack{
                HStack{
                    ZStack{
                    Circle()
                        .stroke(Color.white,lineWidth: 2)
                        Image(systemName : "plus")
                            .rotationEffect(.degrees(45))
                            .foregroundColor(.white)
                    }
                    .frame(width: Screen.maxWidth*0.07, height: Screen.maxWidth*0.07, alignment: .center)
                    .onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button {
                        self.inAppPurchaseViewModel.restoreProducts()
                    } label: {
                        Text("Restore")
                            .bold()
                            .foregroundColor(.white)
                    }

                }
                .padding(.leading).padding(.trailing)
               
            Image("watch")
                .resizable()
                .scaledToFit()
                .frame(width: Screen.maxWidth*0.75, height: Screen.maxWidth*0.75, alignment: .center)
                
                VStack(spacing:6){
                Text("Apple Watch\nBrowser")
                    .bold()
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Full Access. No ads. No limited create pages.")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                }
                 
                Button {
                    self.inAppPurchaseViewModel.selectSubscription = .monthly
                    self.inAppPurchaseViewModel.myProduct = self.inAppPurchaseViewModel.myProducts.first
                    print(self.inAppPurchaseViewModel.myProduct!.price)
                } label: {
                    HStack{
                    Text("One Month ($19.99)")
                            .bold()
                        .foregroundColor(self.inAppPurchaseViewModel.selectSubscription == .monthly ? Color("blue") : .black)
                      Spacer()
                        ZStack{
                        RoundedRectangle(cornerRadius: Screen.maxWidth*0.013)
                                .stroke(self.inAppPurchaseViewModel.selectSubscription == .monthly ? Color("blue") : Color.gray.opacity(0.5),lineWidth: 1.5)
                            .frame(width: Screen.maxWidth*0.07, height: Screen.maxWidth*0.07, alignment: .center)
                            if self.inAppPurchaseViewModel.selectSubscription == .monthly{
                                Image(systemName:"checkmark")
                                    .foregroundColor(Color("blue"))
                            }
                        }
                            
                    }
                    .padding()
                        .frame(width: Screen.maxWidth*0.9)
                        .background(Color.white)
                        .cornerRadius(Screen.maxWidth*0.03)
                    
                }
                
                Button {
                    self.inAppPurchaseViewModel.selectSubscription = .oneTime
                    self.inAppPurchaseViewModel.myProduct = self.inAppPurchaseViewModel.myProducts.last
                    print(self.inAppPurchaseViewModel.myProduct!.price)
                } label: {
                    HStack{
                    Text("One Time ($49.99)")
                            .bold()
                        .foregroundColor(self.inAppPurchaseViewModel.selectSubscription == .oneTime ? Color("blue") : .black)
                      Spacer()
                        ZStack{
                        RoundedRectangle(cornerRadius: Screen.maxWidth*0.013)
                                .stroke(self.inAppPurchaseViewModel.selectSubscription == .oneTime ? Color("blue") : Color.gray.opacity(0.5),lineWidth: 1.5)
                            .frame(width: Screen.maxWidth*0.07, height: Screen.maxWidth*0.07, alignment: .center)
                            if self.inAppPurchaseViewModel.selectSubscription == .oneTime{
                                Image(systemName:"checkmark")
                                    .foregroundColor(Color("blue"))
                            }
                        }
                            
                    }
                    .padding()
                        .frame(width: Screen.maxWidth*0.9)
                        .background(Color.white)
                        .cornerRadius(Screen.maxWidth*0.03)
                    
                }
                
                Text("Try Lorem unlimited for 7 days, then\n$49.99/Year (Just $19.99/Week)")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                    .padding(.top,10)

                Button {
                    self.inAppPurchaseViewModel.onMakePaymentTapped()
                    print(self.inAppPurchaseViewModel.myProduct!.price)
                } label: {
                    HStack{
                    Text("Try Free & Subscribe")
                            .bold()
                            .foregroundColor(.white)

                            
                    }
                    .padding()
                        .frame(width: Screen.maxWidth*0.9)
                        .background(LinearGradient(colors: [Color("lightBlue2"),Color("lightBlue2"),Color("lightBlue")], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(Screen.maxWidth*0.03)
                }
                Text("Auto-renewable. Cancel anytime")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                    
                  
            }
            
        }
        .onAppear {
            self.inAppPurchaseViewModel.fetchProducts()
        }
        .overlay(
            ZStack{
                Color.black.opacity(0.3).ignoresSafeArea()
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50, alignment: .center)
                    ProgressView()
                        .padding()
                       
                }
                    
            }
                .opacity(self.inAppPurchaseViewModel.showLoader ? 1 : 0)
            
        )
    }
}

struct InAppPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchaseView(inAppPurchaseViewModel: InAppPurchaseViewModel())
    }
}
