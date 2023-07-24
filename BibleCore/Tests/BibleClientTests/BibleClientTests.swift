//
//  BibleClientTests.swift
//  
//
//  Created by Peter Larson on 7/20/23.
//

import XCTest
@testable import BibleClient

final class BibleClientTests: XCTestCase {
    
    let client = BibleClient.liveValue
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBookCall() async {
        let results = try? await client.books()
        
        XCTAssertNotNil(results)

        dump(results!)
    }
    
    func testBookChapter() async {
        let books = try? await client.books()
        let book = books?.first
        
        XCTAssertNotNil(book)
        
        let chapters = try? await client.chapters(book!.id)
        
        XCTAssertNotNil(chapters)
        
        dump(chapters!)
    }
    
    func testBookChapterVerses() async {
        let books = try? await client.books()
        let book = books?.first
        
        XCTAssertNotNil(book)
        
        let chapters = try? await client.chapters(book!.id)
        let chapter = chapters?.first
        XCTAssertNotNil(chapter)
        
        do {
            let verses = try await client.verses(book!.id, chapter!.id)
            XCTAssertNotNil(verses)
            
            dump(verses)
        } catch {
            print(error)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
