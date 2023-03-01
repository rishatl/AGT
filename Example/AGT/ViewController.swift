//
//  ViewController.swift
//  AGT
//
//  Created by Латыпов Ришат Ильдарович on 12/13/2022.
//  Copyright (c) 2022 Латыпов Ришат Ильдарович. All rights reserved.
//

import AGT
import UIKit

class ViewController: UIViewController {

    var session: URLSession!
    var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        let testView = UIView()
        testView.backgroundColor = .red
        testView.accessibilityIdentifier = "iddd"
        view.addSubview(testView)
        testView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testView.widthAnchor.constraint(equalToConstant: 100),
            testView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let testView2 = UIView()
        testView2.backgroundColor = .black
        testView2.accessibilityIdentifier = "some id"
        testView.addSubview(testView2)
        testView2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testView2.centerXAnchor.constraint(equalTo: testView.centerXAnchor),
            testView2.centerYAnchor.constraint(equalTo: testView.centerYAnchor),
            testView2.widthAnchor.constraint(equalToConstant: 50),
            testView2.heightAnchor.constraint(equalToConstant: 50)
        ])

        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Send request", for: [])
        button.layer.cornerRadius = 20
        button.accessibilityIdentifier = "btn id"
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: testView.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: testView.centerXAnchor),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            view.rightAnchor.constraint(equalTo: button.rightAnchor, constant: 32),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        button.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
    }

    private func handleCompletion(error: String?, data: Data?) {
        DispatchQueue.main.async {

            if let error = error {
                NSLog(error)
                return
            }

            if let data = data {
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                } catch {

                }
            }
        }
    }

    @objc private func sendRequest() {
        dataTask?.cancel()

        if session == nil {
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        }

        guard let url = URL(string: "https://api.chucknorris.io/jokes/random") else { return }
        let request = URLRequest(url: url)
        dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                self.handleCompletion(error: error.localizedDescription, data: data)
            } else {
                guard let data = data else { self.handleCompletion(error: "Invalid data", data: nil); return }
                guard let response = response as? HTTPURLResponse else { self.handleCompletion(error: "Invalid response", data: data); return }
                guard response.statusCode >= 200 && response.statusCode < 300 else { self.handleCompletion(error: "Invalid response code", data: data); return }

                self.handleCompletion(error: error?.localizedDescription, data: data)
            }
        }

        dataTask?.resume()
    }
}

extension ViewController : URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
    }
}
