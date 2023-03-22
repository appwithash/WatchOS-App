//
//  BackgroundView.swift
//  Apple watch browser
//
//  Created by ashutosh on 28/01/22.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack{
            ZStack{
                Color("blueBg")
                    .opacity(0.3)
                    .ignoresSafeArea()
                Circle()
                    .fill(Color("blueBg"))
                    .frame(width: Screen.maxWidth, height: Screen.maxWidth)
                    .blur(radius: 70)
                    .offset(x: Screen.maxWidth*0.2, y: Screen.maxWidth*0.8)
                Circle()
                    .fill(Color("blueBg"))
                    .frame(width: Screen.maxWidth, height: Screen.maxWidth)
                    .blur(radius: 70)
                    .offset(x: -Screen.maxWidth*0.3, y: -Screen.maxWidth*0.8)
                VStack{
                    ZStack{
                        Circle()
                            .trim(from: 0.7, to: 1)
                            .stroke(Color.blue.opacity(0.1))
                            .frame(width: Screen.maxWidth*0.4, height: Screen.maxWidth*0.4)
                            .rotationEffect(.degrees(-35))
                        Circle()
                            .trim(from: 0.7, to: 1)
                            .stroke(Color.blue.opacity(0.1))
                            .frame(width: Screen.maxWidth*0.6, height: Screen.maxWidth*0.6)
                            .rotationEffect(.degrees(-35))
                        Circle()
                            .trim(from: 0.7, to: 1)
                            .stroke(Color.blue.opacity(0.1))
                            .frame(width: Screen.maxWidth*0.8, height: Screen.maxWidth*0.8)
                            .rotationEffect(.degrees(-35))
                        
                        Circle()
                            .trim(from: 0.7, to: 1)
                            .stroke(Color.blue.opacity(0.1))
                            .frame(width: Screen.maxWidth, height: Screen.maxWidth)
                            .rotationEffect(.degrees(-35))
                    }
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
