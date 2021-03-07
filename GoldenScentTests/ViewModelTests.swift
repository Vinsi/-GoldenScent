//
//  ViewModelTests.swift
//  GoldenScentTests
//
//  Created by Vinsi on 07/03/2021.
//

import XCTest
@testable import GoldenScent
class ViewModelTests: XCTestCase {
    var viewModel: MainViewController.ViewModel?
    class MockRepo: MainViewController.Repository {}
    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = MainViewController.ViewModel(repo: MockRepo(jsonFileName: "mock_layout"))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testinit() throws {
        let expectation = XCTestExpectation(description: "load complete")
        viewModel?.load {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
    
    func testAttributes() throws {
        let expectation = XCTestExpectation(description: "load complete")
        viewModel?.load { [weak self] in
            XCTAssertEqual(self?.viewModel?.numberOfSections, 2)
            XCTAssertEqual(self?.viewModel?.numberOfRows(section: 1), 3)
            XCTAssertEqual(self?.viewModel?.sectionType(section: 0),.customSlider)
            XCTAssertEqual(self?.viewModel?.rowitem(section: 0)?.columns?.count,1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
