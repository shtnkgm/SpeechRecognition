//
//   TagListView.swift
//  SpeechRecognition
//
//  Created by shtnkgm on 2021/05/16.
//

import SwiftUI

struct TagListView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let itemSpacing: CGFloat
    let lineSpacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var width: CGFloat = 0

    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    width = size.width
                }

            _TagListView(
                width: width,
                items: items,
                itemSpacing: itemSpacing,
                lineSpacing: lineSpacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

// swiftlint:disable:next type_name
struct _TagListView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let width: CGFloat
    let items: Data
    let itemSpacing: CGFloat
    let lineSpacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var itemsSize: [Data.Element: CGSize] = [:]

    var body: some View {
        VStack(alignment: alignment, spacing: lineSpacing) {
            ForEach(rows, id: \.self) { rowItems in
                HStack(spacing: itemSpacing) {
                    ForEach(rowItems, id: \.self) { item in
                        content(item)
                            .fixedSize()
                            .readSize { size in
                                itemsSize[item] = size
                            }
                    }
                }
            }
        }
    }

    var rows: [[Data.Element]] {
        var result: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = width

        items.forEach { item in
            let itemWidth = (itemsSize[item] ?? CGSize(width: width, height: 1)).width

            if remainingWidth >= itemWidth {
                result[currentRow].append(item)
            } else {
                currentRow += 1
                result.append([item])
                remainingWidth = width
            }
            remainingWidth -= itemWidth + itemSpacing
        }
        return result
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct TagListView_Previews: PreviewProvider {
    @State static var data: [String] = [
        "🍓いちご",
        "🥦ブロッコリー",
        "🌶️とうがらし",
        "🧅たまねぎ",
        "🍆なす",
        "🍍パイナップル",
        "🥕にんじん",
        "🍑もも"
    ]

    static var previews: some View {
        TagListView(
            items: data,
            itemSpacing: 8,
            lineSpacing: 16,
            alignment: .leading
        ) { item in
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
                Text(item)
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(.all, 8)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(8)
        }
        .padding(.all, 16)
        .background(Color(.systemYellow))
        .cornerRadius(20)
        .padding(.all, 16)
        .previewLayout(.sizeThatFits)
    }
}
