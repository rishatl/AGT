//
//  AGTAuthentificationChallengeSender.swift
//  AGT
//
//  Created by r.latypov on 13.12.2022.
//

import Foundation

class AGTAuthenticationChallengeSender : NSObject, URLAuthenticationChallengeSender {

    typealias AGTAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    let handler: AGTAuthenticationChallengeHandler

    init(handler: @escaping AGTAuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }

    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }

    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }

    func cancel(_ challenge: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }

    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }

    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
