//
//  AGTProtocol.swift
//  AGT
//
//  Created by r.latypov on 12.12.2022.
//

import Foundation

@objc
open class AGTProtocol: URLProtocol {
    static let AGTInternalKey = "com.AGT.AGTInternal"

    private lazy var session: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    private let model = AGTHTTPModel()
    private var response: URLResponse?
    private var responseData: NSMutableData?

    override open class func canInit(with request: URLRequest) -> Bool {
        return canServeRequest(request)
    }

    override open class func canInit(with task: URLSessionTask) -> Bool {
        if task is URLSessionWebSocketTask {
            return false
        }

        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }

    private class func canServeRequest(_ request: URLRequest) -> Bool {
        guard AGT.sharedInstance().isEnabled() else {
            return false
        }

        guard URLProtocol.property(forKey: AGTProtocol.AGTInternalKey, in: request) == nil,
            let url = request.url,
            (url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https")) else {
            return false
        }

        let absoluteString = url.absoluteString
        guard !AGT.sharedInstance().getIgnoredURLs().contains(where: { absoluteString.hasPrefix($0) }) else {
            return false
        }

        let regexMatches = AGT.sharedInstance().getIgnoredURLsRegexes()
            .map({ return $0.matches(url.absoluteString) })
            .reduce(false) {$0 || $1}

        guard regexMatches == false else {
            return false
        }

        return true
    }

    override open func startLoading() {
        model.saveRequest(request)

        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: AGTProtocol.AGTInternalKey, in: mutableRequest)
        session.dataTask(with: mutableRequest as URLRequest).resume()
    }

    override open func stopLoading() {
        session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach { $0.cancel() }
            self.session.invalidateAndCancel()
        }
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
           do {
               try self.init(pattern: pattern)
           } catch {
               preconditionFailure("Illegal regular expression: \(pattern).")
           }
       }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension AGTProtocol: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData?.append(data)
        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        responseData = NSMutableData()

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: AGT.swiftSharedInstance.cacheStoragePolicy)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }

        guard let request = task.originalRequest else {
            return
        }

        model.saveRequestBody(request)

        if error != nil {
            model.saveErrorResponse()
        } else if let response = response {
            let data = (responseData ?? NSMutableData()) as Data
            model.saveResponse(response, data: data)
        }

        AGTHTTPModelManager.shared.add(model)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {

        let updatedRequest: URLRequest
        if URLProtocol.property(forKey: AGTProtocol.AGTInternalKey, in: request) != nil {
            let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.removeProperty(forKey: AGTProtocol.AGTInternalKey, in: mutableRequest)

            updatedRequest = mutableRequest as URLRequest
        } else {
            updatedRequest = request
        }

        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let wrappedChallenge = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: AGTAuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
