//  Created by Sumeet Bajaj on 23.11.23.
import SwiftUI
@available(iOS 15.0,*)
protocol StepsProgressStore: ObservableObject {
    var numberOfSteps: Int { get }
    var currentStep: Int { get }
    var axis: Axis { get }
}
@available(iOS 15.0,*)
class StepsProgressStoreImpl: StepsProgressStore {
    @Published var numberOfSteps: Int = 4
    @Published var currentStep: Int = 3
    @Published var axis = Axis.vertical
}
@available(iOS 15.0,*)
struct StepsProgressView<S: StepsProgressStore>: View {
    @EnvironmentObject var store: S
    @State private var animationAmount = 1.0
    var body: some View {
        makeStack.animation(.linear(duration: 0.3), value: store.currentStep)
    }
    @ViewBuilder private var makeStack: some View {
        if store.axis == .horizontal {
            HStack(spacing: 0) {
                makeSteps
            }
        } else {
            VStack(spacing: 0) {
                makeSteps
            }
        }
    }
    @ViewBuilder private var makeSteps: some View {
        ForEach(1...store.numberOfSteps, id: \.self) { step in
            makeStep(step: step)
            makeSeparator(step: step)
        }
    }
    @ViewBuilder private func makeStep(step: Int) -> some View {
        ZStack {
            if step == store.currentStep || (store.currentStep > store.numberOfSteps && step == store.numberOfSteps) {
               makeAnimatedStep
            }
            Circle()
                .fill( step <= store.currentStep ? .green : .gray)
        }.frame(width: 20, height: 20)
    }
    @ViewBuilder private var makeAnimatedStep: some View {
        Circle()
            .fill(.clear)
            .overlay {
                Circle()
                    .stroke(.green, lineWidth: 10)
                    .scaleEffect(animationAmount)
                    .opacity(Double(1.5 - animationAmount))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: animationAmount
                    )
            }
            .onAppear {
                        animationAmount = 1.5
            }
    }
    @ViewBuilder private func makeSeparator(step: Int) -> some View {
        if step < store.numberOfSteps {
            let size = separatorSize
            Rectangle()
                .fill(step >= store.currentStep ? .gray : .green)
                .frame(width: size.width, height: size.height)
        }
    }

    private var separatorSize: CGSize {
        guard store.axis == .horizontal else {
            return CGSize(width: 2, height: 20)
        }
        return CGSize(width: 20, height: 2)
    }
}
@available(iOS 15.0,*)
struct StepsProgressView_Preview: PreviewProvider {
    static var previews: some View {
        StepsProgressView<StepsProgressStoreImpl>()
            .environmentObject(StepsProgressStoreImpl())
    }
}
