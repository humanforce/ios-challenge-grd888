//
//  CloudInfo.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/28/24.
//

import SwiftUI

struct CloudInfo: View {
    let description: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 0) {
            if !icon.isEmpty {
                Image(icon)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            Text(description)
                .font(.title2)
                .foregroundStyle(Color.primary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.lightBlueStart),
                            Color(.lightBlueEnd)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.primary.opacity(0.2), radius: 5, x: 0, y: 5)
                .padding(30)
    }
}

#Preview {
    CloudInfo(description: "Mist", icon: "02n")
}
