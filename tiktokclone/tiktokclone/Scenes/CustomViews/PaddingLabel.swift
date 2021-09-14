//
//  PaddingLabel.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import UIKit

@IBDesignable class PaddingLabel: UILabel {

    public var enabledDetectors: [CustomDetectorType] = [.address, .phoneNumber, .url, .transitInformation]
    public var rangesForDetectors: [CustomDetectorType: [(NSRange, TextCheckingType)]] = [:]
    public static var defaultAttributes: [NSAttributedString.Key: Any] = {
        return [.font: R.font.milliardExtraLight(size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.white
        ]
    }()

    open internal(set) var addressAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var dateAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var phoneNumberAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var urlAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var transitInformationAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var hashtagAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var mentionAttributes: [NSAttributedString.Key: Any] = defaultAttributes

    open internal(set) var customAttributes: [NSRegularExpression: [NSAttributedString.Key: Any]] = [:]

    open internal(set) var mentionData: [String: String] = [:]

    open var textInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        textContainerSize = CGSize(width: insetRect.width, height: insetRect.height)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.horizontal,
                      height: size.height + textInsets.vertical)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - textInsets.horizontal
        }
    }

    private var textContainerSize: CGSize = .zero
    private var mentionRanges = [(NSRange, TextCheckingType)]()
    private var mentionAllRegex: String = "\\W*(all|All)\\W*"
}

//MARK: - Public functions
extension PaddingLabel {
    public func resetData() {
        self.mentionRanges.removeAll()
        self.mentionData = [:]
        self.rangesForDetectors = [:]
        self.attributedText = nil
        self.text = nil
        self.hashtagAttributes = PaddingLabel.defaultAttributes
        self.mentionAttributes = PaddingLabel.defaultAttributes
        self.addressAttributes = PaddingLabel.defaultAttributes
        self.dateAttributes = PaddingLabel.defaultAttributes
        self.phoneNumberAttributes = PaddingLabel.defaultAttributes
        self.urlAttributes = PaddingLabel.defaultAttributes
        self.transitInformationAttributes = PaddingLabel.defaultAttributes
    }

    public func stringIndex(at point: CGPoint, font: UIFont) -> Int {
        guard let attributedString = self.attributedText else { return -1 }
        var point = point
        point.x -= textInsets.left
        point.y -= textInsets.top
        let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
        // Add font so the correct range is returned for multi-line labels
        mutableAttribString.addAttributes([.font: font], range: NSRange(location: 0, length: attributedString.length))

        let textStorage = NSTextStorage(attributedString: mutableAttribString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: textContainerSize)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.glyphIndex(for: point, in: textContainer)

        let lineRect = layoutManager.lineFragmentUsedRect(forGlyphAt: index, effectiveRange: nil)
        
        var characterIndex: Int?
        
        if lineRect.contains(point) {
            characterIndex = layoutManager.characterIndexForGlyph(at: index)
        }
        
        return characterIndex ?? -1
    }

//    public func stringIndex(at point: CGPoint, font: UIFont) -> Int {
//        guard let attributedString = self.attributedText else { return -1 }
//        var point = point
//        point.x -= textInsets.left
//        point.y -= textInsets.top
//        let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
//        // Add font so the correct range is returned for multi-line labels
//        mutableAttribString.addAttributes([.font: font], range: NSRange(location: 0, length: attributedString.length))
//
//        let textStorage = NSTextStorage(attributedString: mutableAttribString)
//        let layoutManager = NSLayoutManager()
//        textStorage.addLayoutManager(layoutManager)
//        let textContainer = NSTextContainer(size: textContainerSize)
//        textContainer.lineFragmentPadding = 0
//        textContainer.maximumNumberOfLines = self.numberOfLines
//        textContainer.lineBreakMode = self.lineBreakMode
//        layoutManager.addTextContainer(textContainer)
//
//        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//        return index
//    }

    public func parseDetectors(attributedText: NSAttributedString) -> NSAttributedString {
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        mentionRanges = [(NSRange, TextCheckingType)]()

        if self.mentionData.count > 0 {
            for (id, displayName) in self.mentionData {
                var removedCharactersCount: Int = 0
                let mentionText = "@" + displayName
//                let mentionText = displayName.matches(for: mentionAllRegex).count > 0 ? "@" + displayName : displayName
                let ranges = mutableText.customAddAttributes(mentionAttributes, text: mentionText)
                for var range in ranges {
                    if removedCharactersCount > 0 {
                        // Because we removed `removedCharactersCount` characters in mutableText
                        // so we reduce the location of next range in the iteration by `removedCharactersCount`
                        range.location = range.location - removedCharactersCount >= 0
                            ? range.location - removedCharactersCount
                            : 0
                    }
                    
                    if mentionText.matches(for: RegexPatterns.mentionedAll.rawValue).count > 0 {
                        let tuple: (NSRange, TextCheckingType) = (range, .mentionAll)
                        mentionRanges.append(tuple)
                    } else {
                        // Replace "@displayName" with "displayName"
                        mutableText.replaceCharacters(in: range, with: displayName)
                        // Update mention range after replacing text
                        range = NSMakeRange(range.location, range.length - 1)
                        let tuple: (NSRange, TextCheckingType) = (range, .mention(id))
                        mentionRanges.append(tuple)
                        removedCharactersCount += 1
                    }
                }
            }
        }

        rangesForDetectors.updateValue(mentionRanges, forKey: .mention)

        let results = self.parse(text: mutableText)
        self.setRangesForDetectors(in: results)

        guard rangesForDetectors.count > 0 else { return attributedText }
        for (detector, rangeTuples) in rangesForDetectors {
            if enabledDetectors.contains(detector) {
                switch detector {
                case .mention:
                    break
                default:
                    let attributes = detectorAttributes(for: detector)
                    rangeTuples.forEach { (range, _) in
                        mutableText.addAttributes(attributes, range: range)
                    }
                }
            }
        }

        return NSAttributedString(attributedString: mutableText)
    }
}

// MARK: - Private functions
extension PaddingLabel {
    private func parse(text: NSAttributedString) -> [NSTextCheckingResult] {
        guard enabledDetectors.isEmpty == false else { return [] }
        let range = NSRange(location: 0, length: text.length)
        var matches = [NSTextCheckingResult]()

        // Get matches of all .custom DetectorType and add it to matches array
        let regexs = enabledDetectors
            .filter { $0.isCustom }
            .map { parseForMatches(with: $0, in: text, for: range) }
            .joined()
        matches.append(contentsOf: regexs)

        // Get all Checking Types of detectors, except for .custom because they contain their own regex
        let detectorCheckingTypes = enabledDetectors
            .filter { !$0.isCustom }
            .filter { $0 != .mention }
            .reduce(0) { $0 | $1.textCheckingType.rawValue }
        if detectorCheckingTypes > 0, let detector = try? NSDataDetector(types: detectorCheckingTypes) {
            let detectorMatches = detector.matches(in: text.string, options: [], range: range)
            matches.append(contentsOf: detectorMatches)
        }

        guard enabledDetectors.contains(.url) else {
            return matches
        }

        // Enumerate NSAttributedString NSLinks and append ranges
        var results: [NSTextCheckingResult] = matches

        text.enumerateAttribute(NSAttributedString.Key.link, in: range, options: []) { value, range, _ in
            guard let url = value as? URL else { return }
            let result = NSTextCheckingResult.linkCheckingResult(range: range, url: url)
            results.append(result)
        }
        
        for mentionRange in mentionRanges {
            if let index = results.firstIndex(where: {  $0.range == mentionRange.0 }) {
                results.remove(at: index)
            }
        }

        return results
    }

    private func parseForMatches(with detector: CustomDetectorType, in text: NSAttributedString, for range: NSRange) -> [NSTextCheckingResult] {
        switch detector {
        case .custom(let regex):
            return regex.matches(in: text.string, options: [], range: range)
        default:
            fatalError("You must pass a .custom DetectorType")
        }
    }

    private func setRangesForDetectors(in checkingResults: [NSTextCheckingResult]) {
        guard checkingResults.isEmpty == false else { return }

        for result in checkingResults {

            switch result.resultType {
            case .address:
                var ranges = rangesForDetectors[.address] ?? []
                let tuple: (NSRange, TextCheckingType) = (result.range, .addressComponents(result.addressComponents))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .address)
            case .date:
                var ranges = rangesForDetectors[.date] ?? []
                let tuple: (NSRange, TextCheckingType) = (result.range, .date(result.date))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .date)
            case .phoneNumber:
                var ranges = rangesForDetectors[.phoneNumber] ?? []
                let tuple: (NSRange, TextCheckingType) = (result.range, .phoneNumber(result.phoneNumber))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .phoneNumber)
            case .link:
                var ranges = rangesForDetectors[.url] ?? []
                let tuple: (NSRange, TextCheckingType) = (result.range, .link(result.url))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .url)
            case .transitInformation:
                var ranges = rangesForDetectors[.transitInformation] ?? []
                let tuple: (NSRange, TextCheckingType) = (result.range, .transitInfoComponents(result.components))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .transitInformation)
            case .regularExpression:
                guard let text = text, let regex = result.regularExpression, let range = Range(result.range, in: text) else { return }
                let detector = CustomDetectorType.custom(regex)
                var ranges = rangesForDetectors[detector] ?? []
                let tuple: (NSRange, TextCheckingType) = (result.range, .custom(pattern: regex.pattern, match: String(text[range])))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: detector)
            default:
                fatalError("Received an unrecognized NSTextCheckingResult.CheckingType")
            }

        }
    }

    private func updateAttributes(for detectors: [CustomDetectorType]) {
        guard let attributedText = attributedText, attributedText.length > 0 else { return }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)

        for detector in detectors {
            guard let rangeTuples = rangesForDetectors[detector] else { continue }

            for (range, _)  in rangeTuples {
                // This will enable us to attribute it with our own styles, since `UILabel` does not provide link attribute overrides like `UITextView` does
                if detector.textCheckingType == .link {
                    mutableAttributedString.removeAttribute(NSAttributedString.Key.link, range: range)
                }

                let attributes = detectorAttributes(for: detector)
                mutableAttributedString.addAttributes(attributes, range: range)
            }

            let updatedString = NSAttributedString(attributedString: mutableAttributedString)
            self.attributedText = updatedString
        }
    }

    private func detectorAttributes(for detectorType: CustomDetectorType) -> [NSAttributedString.Key: Any] {
        switch detectorType {
        case .address:
            return addressAttributes
        case .date:
            return dateAttributes
        case .phoneNumber:
            return phoneNumberAttributes
        case .url:
            return urlAttributes
        case .transitInformation:
            return transitInformationAttributes
        case .mention:
            return mentionAttributes
        case .hashtag:
            return hashtagAttributes
        case .custom(let regex):
            return customAttributes[regex] ?? PaddingLabel.defaultAttributes
        }
    }
}
