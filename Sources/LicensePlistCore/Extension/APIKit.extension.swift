import Foundation
import APIKit
import Result

extension Session: LicensePlistCompatible {}

extension LicensePlistExtension where Base: Session {
    func sendSync<T: Request>(_ request: T) -> Result<T.Response, SessionTaskError> {
        var result: Result<T.Response, SessionTaskError>!
        let semaphore = DispatchSemaphore(value: 0)
        self.base.send(request, callbackQueue: .sessionQueue) { _result in
            result = _result
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    func send<T: Request>(_ request: T) -> ResultOperation<T.Response, SessionTaskError> {
        return ResultOperation<T.Response, SessionTaskError> { _ in
            return self.sendSync(request)
        }
    }
}
