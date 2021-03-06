// https://github.com/Quick/Quick

import Quick
import Nimble
import AsyncKit

class AsySpec: QuickSpec {
    override func spec() {
        let async = AsyncKit<String, NSError>()

        describe("parallel") {
            it("can be done") {
                waitUntil { done in
                    async.parallel(
                        [
                            { done in done(.success("1")) },
                            { done in
                                DispatchQueue.main.async {
                                    done(.success("2"))
                                }
                            }
                        ]) { result in
                            switch result {
                            case .success(let objects):
                                expect(objects) == ["1", "2"]
                                done()
                            case .failure(_):
                                fail()
                            }
                    }
                }
            }
        }

        describe("series") {
            it("can be done") {
                waitUntil { done in
                    async.series(
                        [
                            { done in done(.success("1")) },
                            { done in
                                DispatchQueue.main.async {
                                    done(.success("2"))
                                }
                            }
                        ]) { result in
                            switch result {
                            case .success(let objects):
                                expect(objects) == ["1", "2"]
                                done()
                            case .failure(_):
                                fail()
                            }
                    }
                }
            }
        }

        describe("whilst") {
            it("can be done") {
                waitUntil { done in
                    var count = 0
                    async.whilst({ return count < 3 },
                        { done in
                            count += 1
                            DispatchQueue.main.async {
                                done(.success(String(count)))
                            }
                        }) { result in
                            switch result {
                            case .success(let object):
                                expect(object) == "3"
                                done()
                            case .failure(_):
                                fail()
                            }
                    }
                }
            }
        }

        describe("waterfall") {
            it("can be done") {
                waitUntil { done in
                    async.waterfall("0",
                        [
                            { argument, done in
                                expect(argument) == "0"
                                done(.success("1"))
                            },
                            { argument, done in
                                expect(argument) == "1"
                                DispatchQueue.main.async {
                                    done(.success("2"))
                                }
                            }
                        ]) { result in
                            switch result {
                            case .success(let objects):
                                expect(objects) == "2"
                                done()
                            case .failure(_):
                                fail()
                            }
                    }
                }
            }
        }
    }
}
