//
//  GrowingTextView.swift
//  TextViewSample
//

import SwiftUI
import UIKit

struct GrowingTextView: UIViewRepresentable {
    @Binding var text: String
    let maxLineCount: Int

    init(text: Binding<String>, maxLineCount: Int = 3) {
        self._text = text
        self.maxLineCount = maxLineCount
    }

    func makeUIView(context: Context) -> InternalTextView {
        let textView = InternalTextView()
        textView.maxLineCount = maxLineCount
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 18)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return textView
    }

    func updateUIView(_ textView: InternalTextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: InternalTextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }

        let textWidth = width - uiView.textContainerInset.left - uiView.textContainerInset.right
        let textHeight = uiView.calculateTextHeight(for: textWidth)
        let maxHeight = uiView.calculateMaxHeight()
        let clampedHeight = min(textHeight, maxHeight)

        return CGSize(width: width, height: clampedHeight)
    }

    // MARK: - Internal TextView

    final class InternalTextView: UITextView {
        
        var maxLineCount: Int = .zero

        func calculateSingleLineHeight() -> CGFloat {
            guard let font = font else { return .zero }

            let singleLineText = NSAttributedString(
                string: "A",
                attributes: [.font: font]
            )

            let boundingRect = singleLineText.boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )

            return ceil(boundingRect.height)
        }

        func calculateMaxHeight() -> CGFloat {
            let singleLineHeight = calculateSingleLineHeight()
            let insets = textContainerInset
            return singleLineHeight * CGFloat(maxLineCount) + insets.top + insets.bottom
        }

        func calculateTextHeight(for width: CGFloat) -> CGFloat {
            guard let font = font else { return calculateSingleLineHeight() }

            let text = self.text ?? ""
            if text.isEmpty {
                return calculateSingleLineHeight()
            }

            let attributedString = NSAttributedString(
                string: text,
                attributes: [.font: font]
            )

            let boundingRect = attributedString.boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )

            return ceil(boundingRect.height) + textContainerInset.top + textContainerInset.bottom
        }

        func updateScrollAndScrollToCaret() {
            let textWidth = bounds.width - textContainerInset.left - textContainerInset.right
            guard textWidth > 0 else { return }

            let textHeight = calculateTextHeight(for: textWidth)
            let maxHeight = calculateMaxHeight()

            // 先にスクロールを有効化
            let shouldScroll = textHeight > maxHeight
            isScrollEnabled = shouldScroll
            invalidateIntrinsicContentSize()

            // その後にカーソル位置へスクロール
            if shouldScroll, let selectedRange = selectedTextRange {
                let caretRect = caretRect(for: selectedRange.end)
                scrollRectToVisible(caretRect, animated: false)
            }
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text

            // スクロール有効化とカーソル位置へのスクロールを実行
            if let internalTextView = textView as? InternalTextView {
                internalTextView.updateScrollAndScrollToCaret()
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack {
        Spacer()
        GrowingTextView(text: $text, maxLineCount: 3)
            .padding(.horizontal, 4)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding()
    }
}
