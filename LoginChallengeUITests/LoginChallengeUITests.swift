import XCTest

class LoginChallengeUITests: XCTestCase {

    private var app: XCUIApplication = XCUIApplication()
    private let waitInterval = TimeInterval(5)

    override func setUpWithError() throws {
        continueAfterFailure = false
        // 毎回きれいな状態で開始したいと思って書いたけどどこまで効果があるのかは忘れた（無いんでしたっけ）
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    ///
    /// 正常ログインケースおよびログイン後確認
    /// （実質シナリオテストの類）
    ///
    /// - Throws:
    func testLogin() throws {

        let loginButton = app.buttons["btnLogin"]

        XCTContext.runActivity(named: "ログインボタンがタップできないこと") { _ in
            waitToAppear(for: loginButton)
            XCTAssertTrue(!loginButton.isEnabled)
        }

        XCTContext.runActivity(named: "IDを入力できること") { _ in
            let text = "koher"
            let tbId = app.textFields["tbId"]
            tbId.tap()
            tbId.typeText(text)
            app.keyboards.buttons["Return"].tap()
            XCTAssertEqual(tbId.firstMatch.value as! String, text)
        }

        XCTContext.runActivity(named: "パスワードをマスクされた状態で入力できること") { _ in
            let text = "1234"
            let tbPassword = app.secureTextFields["tbPw"]
            tbPassword.tap()
            tbPassword.typeText(text)
            app.keyboards.buttons["Return"].tap()
            XCTAssertEqual(tbPassword.firstMatch.value as! String, "••••")
        }

        XCTContext.runActivity(named: "ログインボタンがタップできること") { _ in
            waitToAppear(for: loginButton)
            XCTAssertTrue(loginButton.isEnabled)
        }

        let logoutButton = app.buttons["Logout"]
        XCTContext.runActivity(named: "ログインが成功すること") { _ in
            loginButton.tap()
            wait(for: [expectation(
                    for: NSPredicate(format: "exists == true"),
                    evaluatedWith: logoutButton,
                    handler: .none
            )], timeout: waitInterval)
        }

        XCTContext.runActivity(named: "ログインボタンがタップできること") { _ in
            XCTAssert(logoutButton.isEnabled)
        }

        // SwiftUI対応を考えるとelementを探してlabel検査するよりも、直接文字列検索が望ましい気がした
        XCTContext.runActivity(named: "名前が表示されていること") { _ in
            let text = "Yuta Koshizawa"
            let query = app.staticTexts[text]
            waitToAppear(for: query)
            XCTAssertEqual(query.label, text)
        }

        XCTContext.runActivity(named: "IDが表示されていること") { _ in
            let text = "@koher"
            let query = app.staticTexts[text]
            waitToAppear(for: query)
            XCTAssertEqual(query.label, text)
        }

//        ランダムなテストがやはり微妙なのでいったんコメントアウト。
//        戻すときは APIServices/Sources/APIServices/UserService.swift も修正する
//
//        XCTContext.runActivity(named: "紹介文が表示されていること") { _ in
//            let keyword = "ソフトウェア"
//            let query = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", keyword)).firstMatch
//            waitToAppear(for: query)
//            let text1 = "ソフトウェアエンジニア。 Heart of Swift https://heart-of-swift.github.io を書きました。"
//            let text2 = "ソフトウェアエンジニア。 Swift Zoomin' https://swift-tweets.connpass.com/ を主催しています。"
//            XCTAssert(query.label == text1 || query.label == text2)
//        }

        XCTContext.runActivity(named: "紹介文が表示されていること") { _ in
            let text = "ソフトウェアエンジニア。 Heart of Swift https://heart-of-swift.github.io を書きました。"
            let query = app.staticTexts[text]
            waitToAppear(for: query)
            XCTAssertEqual(query.label, text)
        }

        XCTContext.runActivity(named: "ログアウトが成功すること") { _ in
            logoutButton.tap()
            wait(for: [expectation(
                    for: NSPredicate(format: "exists == true"),
                    evaluatedWith: loginButton,
                    handler: .none
            )], timeout: waitInterval)
        }

    }

    ///
    /// ログインエラー（ID,パスワードの誤り）
    ///
    /// - Throws:
    func testLoginErrorWithWrongCredentials() throws {

        let loginButton = app.buttons["btnLogin"]

        XCTContext.runActivity(named: "ログインボタンがタップできないこと") { _ in
            waitToAppear(for: loginButton)
            XCTAssertTrue(!loginButton.isEnabled)
        }

        XCTContext.runActivity(named: "IDを入力できること") { _ in
            let text = "rehok"
            let tbId = app.textFields["tbId"]
            tbId.tap()
            tbId.typeText(text)
            app.keyboards.buttons["Return"].tap()
            XCTAssertEqual(tbId.firstMatch.value as! String, text)
        }

        XCTContext.runActivity(named: "パスワードをマスクされた状態で入力できること") { _ in
            let text = "4321"
            let tbPassword = app.secureTextFields["tbPw"]
            tbPassword.tap()
            tbPassword.typeText(text)
            app.keyboards.buttons["Return"].tap()
            XCTAssertEqual(tbPassword.firstMatch.value as! String, "••••")
        }

        XCTContext.runActivity(named: "ログインボタンがタップできること") { _ in
            waitToAppear(for: loginButton)
            XCTAssertTrue(loginButton.isEnabled)
        }

        let alert = app.alerts.firstMatch
        XCTContext.runActivity(named: "ログインが失敗すること") { _ in
            loginButton.tap()
            wait(for: [expectation(
                    for: NSPredicate(format: "exists == true"),
                    evaluatedWith: alert,
                    handler: .none
            )], timeout: waitInterval)
            XCTAssertEqual(alert.label, "ログインエラー")
        }

        let closeOnAlert = alert.scrollViews.otherElements.buttons["閉じる"]
        XCTContext.runActivity(named: "エラーダイアログを閉じることが可能であること") { _ in
            wait(for: [expectation(
                    for: NSPredicate(format: "exists == true"),
                    evaluatedWith: closeOnAlert,
                    handler: .none
            )], timeout: waitInterval)
            closeOnAlert.tap()
        }

    }


    ///
    /// 記録用のコードなので不要になったら破棄する
    ///
    /// - Throws:
    func notestLoginRecorded() throws {
        
        let app = XCUIApplication()
        let tbidTextField = app/*@START_MENU_TOKEN@*/.textFields["tbId"]/*[[".otherElements[\"backscreen\"]",".textFields[\"ID\"]",".textFields[\"tbId\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        tbidTextField.tap()
        app/*@START_MENU_TOKEN@*/.keys["k"]/*[[".keyboards.keys[\"k\"]",".keys[\"k\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let oKey = app/*@START_MENU_TOKEN@*/.keys["o"]/*[[".keyboards.keys[\"o\"]",".keys[\"o\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        oKey.tap()
        oKey.tap()
        
        let hKey = app/*@START_MENU_TOKEN@*/.keys["h"]/*[[".keyboards.keys[\"h\"]",".keys[\"h\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        hKey.tap()
        hKey.tap()
        
        let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eKey.tap()
        eKey.tap()
        
        let rKey = app/*@START_MENU_TOKEN@*/.keys["r"]/*[[".keyboards.keys[\"r\"]",".keys[\"r\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        rKey.tap()
        rKey.tap()
        app/*@START_MENU_TOKEN@*/.secureTextFields["tbPw"]/*[[".otherElements[\"backscreen\"]",".secureTextFields[\"PASSWORD\"]",".secureTextFields[\"tbPw\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let key = app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key.tap()
        key.tap()
        
        let key2 = app/*@START_MENU_TOKEN@*/.keys["2"]/*[[".keyboards.keys[\"2\"]",".keys[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key2.tap()
        key2.tap()
        app/*@START_MENU_TOKEN@*/.keys["3"]/*[[".keyboards.keys[\"3\"]",".keys[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["4"]/*[[".keyboards.keys[\"4\"]",".keys[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let returnButton = app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        returnButton.tap()
        
        let loginStaticText = app/*@START_MENU_TOKEN@*/.staticTexts["Login"]/*[[".otherElements[\"backscreen\"]",".buttons[\"Login\"].staticTexts[\"Login\"]",".buttons[\"btnLogin\"].staticTexts[\"Login\"]",".staticTexts[\"Login\"]"],[[[-1,3],[-1,2],[-1,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        loginStaticText.tap()
        app.alerts["ログインエラー"].scrollViews.otherElements.buttons["閉じる"].tap()
        tbidTextField.tap()
        tbidTextField.tap()
        
        let deleteKey = app/*@START_MENU_TOKEN@*/.keys["delete"]/*[[".keyboards.keys[\"delete\"]",".keys[\"delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        hKey.tap()
        hKey.tap()
        eKey.tap()
        rKey.tap()
        rKey.tap()
        returnButton.tap()
        loginStaticText.tap()
        app.alerts["システムエラー"].scrollViews.otherElements.buttons["閉じる"].tap()
        loginStaticText.tap()
        app.staticTexts["Yuta Koshizawa"].tap()
        app.staticTexts["@koher"].tap()
        app.staticTexts["ソフトウェアエンジニア。 Heart of Swift https://heart-of-swift.github.io を書きました。"].tap()
        app.buttons["Refresh"].tap()
        app.buttons["Logout"].tap()
                        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCTestCase {
    func waitToAppear(for element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, file: file, line: line)
    }

    func waitToHittable(for element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        let predicate = NSPredicate(format: "hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, file: file, line: line)
        return element
    }
}
