//
//  ViewController.swift
//  Combine.Future
//
//  Created by Ivan Sapozhnik on 11/2/19.
//  Copyright © 2019 Swifty Talks. All rights reserved.
//

import UIKit
import Contacts
import Combine

class ViewController: UIViewController {
    private var contactsPublisher: AnyPublisher<UIColor?, Never>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsPublisher = Future<Bool, Never> { promise in
            CNContactStore().requestAccess(for: .contacts) { access, error in
                if error != nil {
                    promise(.success(false))
                }
                promise(.success(access))
            }
        }.map { access -> UIColor? in
            access ? .green : .red
        }.eraseToAnyPublisher()

        let subscriber = Subscribers.Assign(object: view, keyPath: \.backgroundColor)
        contactsPublisher.subscribe(subscriber)
    }
}

