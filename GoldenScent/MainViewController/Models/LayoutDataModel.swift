//
//  LayoutDataModel.swift
//  GoldenScent
//
//  Created by Vinsi on 05/03/2021.
//

import Foundation

// MARK: - LayoutDataModel
struct LayoutDataModel: Codable {
    let rows: [Row]?
    enum CodingKeys: String, CodingKey {
        case rows
    }
}

extension LayoutDataModel {
    
    struct LayoutSize: Codable {
        enum Unit: String {
            case pixel = "px"
            case point = "pi"
        }
        var type: Unit
        var value: Double
        init?(string: String) {
            switch true {
            case string.contains(Unit.pixel.rawValue):
                guard let value = Double(string.replacingOccurrences(of: Unit.pixel.rawValue, with: "")) else {
                    return nil
                }
                self.type = .pixel
                self.value = value
            case string.contains(Unit.point.rawValue):
                guard let value = Double(string.replacingOccurrences(of: Unit.point.rawValue, with: "")) else {
                    return nil
                }
                self.type = .point
                self.value = value
            default:
                return nil
            }
            
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let x = try? container.decode(String.self), let obj = LayoutSize(string: x) {
                self = obj
                return
            }
            throw DecodingError.typeMismatch(LayoutSize.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Size"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode("\(value)\(type.rawValue)")
        }
    }
    
    // MARK: - Row
    struct Row: Codable {
        let rowMarginLeft: LayoutSize?
        let rowMarginRight: LayoutSize?
        let rowMarginBottom: LayoutSize?
        let columns: [Column]?
        let height: LayoutSize?
        
        enum CodingKeys: String, CodingKey {
            case rowMarginLeft = "row-margin-left"
            case rowMarginRight = "row-margin-right"
            case rowMarginBottom = "row-margin-bottom"
            case columns
            case height
        }
        
        // MARK: - Column
        struct Column: Codable {
            let type: ContentType?
            let src: String?
            let slides: [Slide]?
            let content: String?
            let textAlign: String?
            let fontColor: String?
            let fontSize: Int?
            let font: String?
            let background: Background?
            
            enum CodingKeys: String, CodingKey {
                case type
                case src
                case slides
                case content
                case textAlign = "text-align"
                case fontColor = "font-color"
                case fontSize = "font-size"
                case font
                case background
            }
            
            // MARK: - Background
            struct Background: Codable {
                let color: String?
                
                enum CodingKeys: String, CodingKey {
                    case color
                }
            }
            // MARK: - Slide
            struct Slide: Codable {
                let type: ContentType?
                let src: String?
                
                enum CodingKeys: String, CodingKey {
                    case type
                    case src
                }
            }
            
            enum ContentType: String, Codable {
                case customSlider = "custom-slider"
                case image = "image"
                case text = "text"
            }
        }
    }
}
