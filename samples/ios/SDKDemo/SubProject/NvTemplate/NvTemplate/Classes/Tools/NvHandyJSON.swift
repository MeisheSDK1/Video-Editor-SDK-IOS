//
//  NvHandyJSON.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit

extension NvHandyJSON {
    static func jsonToModel<T: Decodable>(jsonString: String, modelType: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonString.data(using: .utf8)), let info = try? JSONDecoder().decode(T.self, from: data) else {
                    return nil
                }
        return info
    }
//    static func modelToJson<T: Encodable>(model: T) -> String? {
//        if let data = modelToData(model: model) {
//            return String(data: data, encoding: .utf8)
//        }
//        return nil
//    }
    
    static func mapToModel<T: Decodable>(map: [String: Any], modelType: T.Type) -> T? {
        guard map.count != 0 else { return nil }
        do {
            let obj = try JSONSerialization.data(withJSONObject: map)
            let model = try JSONDecoder().decode(modelType, from: obj)
            return model
        } catch let error {
            print(error)
            return nil
        }
    }
    
//    static func modelToData<T: Encodable>(model: T) -> Data? {
//        guard let data = try? JSONEncoder().encode(model) else {
//            return nil
//        }
//        return data
//    }
    static func dataToModel<T: Decodable>(data: Data?, modelType: T.Type) -> [T] {
        var modelArray: [T] = []
        if let jsonData = data {
            do {
                let obj = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.init())
                if let array = obj as? [T] {
                    array.forEach({
                        if let map: T = mapToModel(map: $0 as! [String: Any], modelType: modelType) {
                            modelArray.append(map)
                        }
                    })
                }else {
                    if let map: T = mapToModel(map: obj as! [String: Any], modelType: modelType) {
                        modelArray.append(map)
                    }
                }
                return modelArray
            } catch {
                return modelArray
            }
        }else {
            return modelArray
        }
    }
    
    static func jsonArrayToModel<T: Decodable>(jsonString: String, modelType: T.Type) -> [T] {
        guard jsonString != "" || jsonString.count != 0 else { return [] }
        var modelArray: [T] = []
        guard let data = jsonString.data(using: .utf8) else { return [] }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]]
            array?.forEach({
                if let map: T = mapToModel(map: $0, modelType: modelType) {
                    modelArray.append(map)
                }
            })
            return modelArray
        } catch {
            return modelArray
        }
    }
    
    static func dictArrayToModel<T: Decodable>(array: Array<[String: Any]>, modelType: T.Type) -> [T] {
        if array.count == 0 { return [] }
        var modelArray: [T] = []
        array.forEach({
            if let map: T = mapToModel(map: $0 , modelType: modelType) {
                modelArray.append(map)
            }
        })
        return modelArray
    }
}
struct NvHandyJSON { }
