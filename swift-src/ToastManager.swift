//
//  YelpReview
//
//  ToastManager.swift
//

import SwiftUI

// Toast View
// https://stackoverflow.com/questions/56550135/swiftui-global-overlay-that-can-be-triggered-from-any-view
struct Toast<Presenting, Content>: View where Presenting: View, Content: View {
    @Binding var isPresented: Bool
    
    let presenter: () -> Presenting
    let content: () -> Content
    let delay: TimeInterval = 2.75

    var body: some View {
        if self.isPresented {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                withAnimation {
                    self.isPresented = false
                }
            }
        }

        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenter()

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray4).opacity(0.85))

                    self.content()
                }
                .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 8)
                .opacity(self.isPresented ? 1 : 0)
            }
            .padding(.bottom)
        }
    }
}

// Extension for Toast View
extension View {
    func toast<Content>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View where Content: View {
        Toast(
            isPresented: isPresented,
            presenter: { self },
            content: content
        )
    }
}
