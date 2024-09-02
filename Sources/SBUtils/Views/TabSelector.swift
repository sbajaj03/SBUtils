import SwiftUI

protocol TabSelectorItem: Identifiable {
    var title: String { get }
}

protocol TabSelectorStore: ObservableObject {
    var tabItems: [any TabSelectorItem] { get }
}

struct TabSelector<S: TabSelectorStore>: View {

    @EnvironmentObject private var store: S

    // MARK: Constants
    private static var hStackContentSpaceName: String { "HStackContentSpaceName" }

    // MARK: - Private Properties
    @State private var contentWidth: CGFloat = 0
    @State private var selectedItemFrame: CGRect = .zero
    @State private var selectedIndex: Int = 0

    // MARK: - Theme Properties
    @State private var backgroundColor: Color = .gray
    @State private var textColor: Color = .white
    @State private var indicatorColor: Color = .white
    @State private var itemSpacing: CGFloat = 8

    // MARK: - CallBack Properties
    private var onItemSelection: ((any TabSelectorItem) -> Void)?

    // MARK: - View Builders
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(backgroundColor)
            makeScrollView
        }
        .frame( height: 40)
    }

    @ViewBuilder private var makeScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .bottom) {
                    makeHStack
                    makeIndicator
                }
                .padding(.horizontal, 10)
            }
            .onChange(of: selectedIndex) { newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onItemSelection?(store.tabItems[newValue])
                }
            }
        }
    }

    @ViewBuilder private var makeHStack: some View {
        HStack(spacing: itemSpacing) {
            ForEach(0..<store.tabItems.count, id: \.self) { value in
                makeItem(index: value)
            }
        }
        .overlay(GeometryReader { stackGeo in
            ZStack {}.onAppear(perform: {
                contentWidth = stackGeo.size.width
            }).onChange(of: stackGeo.size.width) {
                contentWidth = $0
            }
        }, alignment: .center)
        .padding(.bottom, 12)
        .coordinateSpace(name: TabSelector.hStackContentSpaceName)
    }

    @ViewBuilder private var makeIndicator: some View {
        Rectangle()
            .fill(indicatorColor)
            .frame(width: selectedItemFrame.width, height: 3)
            .offset(x: selectedItemFrame.midX - contentWidth / 2)
    }

    @ViewBuilder private func makeItem(index: Int) -> some View {
        Text(store.tabItems[index].title)
            .foregroundColor(textColor)
            .overlay(GeometryReader(content: { geo in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index
                            selectedItemFrame = geo.frame(in: .named(TabSelector.hStackContentSpaceName))
                        }
                    }
                    .onAppear(perform: {
                        if selectedIndex == index {
                            selectedItemFrame = geo.frame(in: .named(TabSelector.hStackContentSpaceName))
                            onItemSelection?(store.tabItems[index])
                        }
                    })
                    .onChange(of: geo.size) { _ in
                        if selectedIndex == index {
                            selectedItemFrame = geo.frame(in: .named(TabSelector.hStackContentSpaceName))
                        }
                    }
            }), alignment: .center)
    }
}

extension TabSelector {

    func setTextColor(_ color: Color) -> Self {
        var newSelf = self
        newSelf._textColor = State(initialValue: color)
        return newSelf
    }

    func setBackgroundColor(_ color: Color) -> Self {
        var newSelf = self
        newSelf._backgroundColor = State(initialValue: color)
        return newSelf
    }

    func setIndicatorColor(_ color: Color) -> Self {
        var newSelf = self
        newSelf._indicatorColor = State(initialValue: color)
        return newSelf
    }

    func setItemSpacing(_ spacing: CGFloat) -> Self {
        var newSelf = self
        newSelf._itemSpacing = State(initialValue: spacing)
        return newSelf
    }

    func onItemSelection(_ perform: @escaping (any TabSelectorItem) -> Void) -> Self {
        var newSelf = self
        newSelf.onItemSelection = perform
        return newSelf
    }
}

#if DEBUG
struct HTabViewPreview: PreviewProvider {

    enum TestTabSelectorItems: String, CaseIterable, TabSelectorItem {
        var title: String { rawValue }
        var id: String { rawValue }
        case one, two, three, four, five, six, seven, eight, nine, ten, twenty, thirty, forty, fifty, sixty, seventy
    }

    class TabSelectorStoreImpl: TabSelectorStore {
        var tabItems: [any TabSelectorItem] = TestTabSelectorItems.allCases
    }

    struct TabSelectorContainer: View {
        @State var selected: (any TabSelectorItem)?
        var body: some View {
            VStack(alignment: .leading) {
                TabSelector<TabSelectorStoreImpl>()
                    .onItemSelection {
                        selected = $0
                    }
                    .environmentObject(TabSelectorStoreImpl())
                if selected != nil {
                    Text("Selected Item -> ") +
                    Text(selected?.title ?? "")
                }
                Spacer()
            }
        }
    }

    static var previews: some View {
        TabSelectorContainer()
    }
}
#endif
