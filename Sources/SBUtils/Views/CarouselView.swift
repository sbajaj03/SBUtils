import SwiftUI

struct CarouselView: View {

    @State var images: [UIImage] = []
    @State var selectedIndex = 0
 
    var body: some View {
        GeometryReader(content: { geometry in
            if images.isEmpty {
                ProgressView().onAppear {
                    loadImages()
                }

            } else {
                ZStack {
                    TabView(selection: $selectedIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            ZStack {
                                Image(uiImage: images[selectedIndex])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }.ignoresSafeArea()
                        }
                    }
                    .frame(width: geometry.size.width)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        })
    }
    
    private var urls:[String] {
       ["https://www.shutterstock.com/image-photo/detail-on-one-led-headlights-260nw-2018441720.jpg",
        "https://www.shutterstock.com/image-illustration/front-view-generic-brandless-moder-260nw-1150043414.jpg",
        "https://media.istockphoto.com/id/909923986/photo/car-view.jpg?s=612x612&w=0&k=20&c=CIWlIYYHaqsxmAgfSTNqxzNQL9wTuiJoyVbGv-PwAjU=",
         "https://cdn2.photostockeditor.com/t/2512/black-and-white-grayscale-photography-of-bmw-coupe-in-front-of-building-vehicle-vehicle-image.jpg",
        "https://www.shutterstock.com/image-photo/detail-on-one-led-headlights-260nw-2018441720.jpg",
         "https://www.shutterstock.com/image-illustration/front-view-generic-brandless-moder-260nw-1150043414.jpg",
         "https://media.istockphoto.com/id/909923986/photo/car-view.jpg?s=612x612&w=0&k=20&c=CIWlIYYHaqsxmAgfSTNqxzNQL9wTuiJoyVbGv-PwAjU=",
          "https://cdn2.photostockeditor.com/t/2512/black-and-white-grayscale-photography-of-bmw-coupe-in-front-of-building-vehicle-vehicle-image.jpg",
       ]
    }
    
    func loadImages() {
        urls.forEach {
            if let data = try? Data(contentsOf: URL(string: $0)!) {
                images.append(UIImage(data: data)!)
            }
        }
    }
}

extension Image {
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!).resizable()
        }
        return self.resizable()
    }
}

#if DEBUG
struct CarouselViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            CarouselView()
                .frame(width: UIScreen.main.bounds.width, height: 300)
            Spacer()
        }.ignoresSafeArea()
    }
}
#endif
