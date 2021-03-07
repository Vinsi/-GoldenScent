//
//  ViewModel.swift
//  GoldenScent
//
//  Created by Vinsi on 05/03/2021.
//

import Foundation
enum RepoError: Error {
    case noData
}

extension Result {
    
    var value: Success? {
        if case .success(let success) = self {
           return success
        }
        return nil
    }
}

protocol LayoutRepositoryType {
    func getLayout(onComplete: (_ result: Result<LayoutDataModel,RepoError> ) -> ())
}

extension MainViewController {
    
    class Repository: LayoutRepositoryType {
        private var jsonFile: String
        init(jsonFileName: String = "data") {
            self.jsonFile = jsonFileName
        }
        func getLayout(onComplete: (Result<LayoutDataModel, RepoError>) -> ()) {
            do {
                guard let result = try JSONUtility().decodeFromJson(named: jsonFile, type: LayoutDataModel.self) else {
                    throw RepoError.noData
                }
                onComplete(.success(result))
            }
            catch {
                onComplete(.failure(.noData))
            }
        }
    }
}

extension MainViewController {
    
    class ViewModel {
        private var data: LayoutDataModel?
        private var repository: LayoutRepositoryType
        init(repo: LayoutRepositoryType = Repository()) {
            repository = repo
        }
        
        func load(onComplete: @escaping (() -> ())) {
            repository.getLayout {
                switch $0 {
                case.success(let result):
                    self.data = result
                case.failure(_):
                    self.data = nil
                }
                onComplete()
            }
        }
        
        func numberOfRows(section: Int) -> Int {
            data?.rows?[section].columns?.count ?? 0
        }
        
        var numberOfSections: Int {
            data?.rows?.count ?? 0
        }
        
        func sectionType(section: Int) -> LayoutDataModel.Row.Column.ContentType? {
            return data?.rows?[section].columns?.first?.type
        }
        
        func columnitem(section: Int, index: Int) -> LayoutDataModel.Row.Column? {
            data?.rows?[section].columns?[index]
        }
        
        func rowitem(section: Int) -> LayoutDataModel.Row? {
            data?.rows?[section]
        }
    }
}
