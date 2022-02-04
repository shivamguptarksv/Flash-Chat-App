
import UIKit
import Firebase
class ChatViewController: UIViewController {
    
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var messageTextfield: UITextField!
   
   let db = Firestore.firestore()
    
   var messages : [Message] = [
      Message(sender: "papa@gmail.com", body: "You Send Some Message"),
      Message(sender: "mammi@gmail.com",body: "I Send Some Message")
   ]
   
   override func viewDidLoad() {
       super.viewDidLoad()
       tableView.dataSource = self
       tableView.delegate = self
       title = K.appName
       navigationItem.hidesBackButton  = true
       
       tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier )
       
       loadMessages()
       
   }
   
    func loadMessages(){
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { ( querySnapshot, error )in
            
            self.messages = []
            if let e = error {
                print("There was a issue retrieving data from firestore : \(e)")
            }else{
                if let snapshotDocument = querySnapshot?.documents{
                    for doc in snapshotDocument{
                        
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String , let messageBody = data[K.FStore.bodyField] as? String
                        {
                            
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
   @IBAction func sendPressed(_ sender: UIButton) {
       if let messageBody = messageTextfield.text , let messageSender = Auth.auth().currentUser?.email {
          
           db.collection(K.FStore.collectionName).addDocument(data: [
            K.FStore.senderField : messageSender,
            K.FStore.bodyField : messageBody ,
            K.FStore.dateField : Date().timeIntervalSince1970
            
           ]) { (error) in
               
               if let e = error {
                   print("There was a issue saving data to firestore : \(e)")
               }else{
                   print("Successfully saved data . ")
                   DispatchQueue.main.async {
                       self.messageTextfield.text  = ""

                   }
                }
               
           }
           
       }
   }
   
   @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
       
        do {
           try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
       } catch let signOutError as NSError {
           print("Error signing out: %@", signOutError)
       }
       
       
   }
    
   @IBAction func deleteChatPressed(_ sender: UIBarButtonItem) {

       db.collection(K.FStore.collectionName).getDocuments() { (querySnapshot, err) in
           if let e = err {
               print("Error getting documents: \(e)")
           } else {
               for document in querySnapshot!.documents {
                   document.reference.delete()
               }
               print("Deleted All Chat From FireStore ")
               
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
           }
       }
    }

}

extension ChatViewController : UITableViewDelegate{
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       print(indexPath.row)
   }
   
}


extension ChatViewController : UITableViewDataSource{
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return messages.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       let message = messages[indexPath.row]
       let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath ) as! MessageCell
       
//     cell.textLabel?.text = messages[indexPath.row].body
       cell.label.text = message.body  // messages[indexPath.row].body
       
       //This is a message from the current user
       if message.sender == Auth.auth().currentUser?.email{
           cell.leftImageView.isHidden = true
           cell.rightImageView.isHidden = false
           cell.label.textAlignment = .right
           //         cell.leftImageView.image = UIImage(systemName: K.trash)
           cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
           cell.label.textColor = UIColor(named: K.BrandColors.purple)
           
       }else{
           cell.leftImageView.isHidden = false
           cell.rightImageView.isHidden = true
           cell.label.textAlignment = .left
           cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
           cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
       }
       
       return cell
   }
}
