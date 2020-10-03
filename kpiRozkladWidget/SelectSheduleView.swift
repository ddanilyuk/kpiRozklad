//
//  SelectSheduleView.swift
//  kpiRozkladWidgetExtension
//
//  Created by Денис Данилюк on 03.10.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SelectSheduleView: View {
    var body: some View {
        Link(destination: URL(string: "kpiRozklad://")!) {
            VStack {
                Spacer(minLength: 0)

                Text("Будь-ласка, оберіть розклад в додатку")
//                    .lineLimit(0)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
//                    .padding()
                Spacer(minLength: 0)
                Button(action: {
                    
                }, label: {
                    Text("Choose")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100, height: 30, alignment: .center)
                        .clipped()
//                        .background(ContainerRelativeShape().fill(Color.orange))

                        .background(Color(#colorLiteral(red: 0.9712373614, green: 0.6793045998, blue: 0, alpha: 1)))

                        .cornerRadius(8)
                })
//                .background(ContainerRelativeShape().fill(Color.gray))

//                Spacer(minLength: 0)

            }
//            .background(ContainerRelativeShape().fill(Color.blue))

        }
        .padding(.all)
    }
}

struct SelectSheduleView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSheduleView()
            .previewContext(
                WidgetPreviewContext(family: .systemMedium))
    }
}
