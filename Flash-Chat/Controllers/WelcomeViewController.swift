
import UIKit

class WelcomeViewController: UIViewController {

   @IBOutlet weak var titleLabel: UILabel!
   
   override func viewDidLoad() {
       super.viewDidLoad()
       
       titleLabel.text = ""
       var chatIndex = 0.0
       let titleText = K.appName
       for letter in titleText{
           
           Timer.scheduledTimer(withTimeInterval: 0.1*chatIndex, repeats: false) { (timer) in
               self.titleLabel.text?.append(letter)
           }
           chatIndex += 1
       }
    
   }
   

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden  = false
        
    }
}
