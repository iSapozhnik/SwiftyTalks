//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Contacts
import Combine

class MyViewController : UIViewController {
    private var contactsPublisher: AnyPublisher<Bool, Error>?
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello Future!"
        label.textColor = .black
        view.addSubview(label)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsPublisher = Future<Bool, Error> { promise in
            CNContactStore().requestAccess(for: .contacts) { access, error in
                if let error = error {
                    promise(.failure(error))
                }
                promise(.success(access))
            }
        }.eraseToAnyPublisher()
    }
}

PlaygroundPage.current.liveView = MyViewController()
