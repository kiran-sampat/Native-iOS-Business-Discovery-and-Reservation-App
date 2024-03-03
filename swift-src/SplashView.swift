//
//  YelpReview
//
//  SplashView.swift
//

import SwiftUI

struct SplashView: View {
    @State private var splash_is_active: Bool = false
    @State private var splash_size: Double = 0.95
    @State private var splash_opacity: Double = 0.95

    var body: some View {
        if self.splash_is_active {
            HomeView()
        } else {
            // Splash View
            VStack {
                Spacer()

                VStack {
                    Image("app_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
//                    Image("app_launch")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200)
//                    Image(systemName: "apple.logo")
//                        .font(.system(size: 80))
//                        .foregroundColor(.red)
//                    Text("Yelp Review App")
//                        .font(.system(size: 30, weight: .bold, design: .rounded))
//                        .foregroundColor(.black.opacity(0.85))
//                        .padding(.top)
                }
                .scaleEffect(self.splash_size)
                .opacity(self.splash_opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.25)) {
                        self.splash_size = 1.0
                        self.splash_opacity = 1.0
                    }
                }

                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                    withAnimation {
                        self.splash_is_active = true
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}

