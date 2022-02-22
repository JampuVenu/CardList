//
//  ViewController.swift
//  CardList
//
//  Created by Venu on 21/02/22.
//

import UIKit
import Alamofire
import LocalAuthentication

class ViewController: UIViewController {
    
    var bioMetricSuccess : String! = ""
    var listArray = NSArray()
    var isSuccess = false
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUi()
        loadDynamicData()
    }
    
    // MARK :- Tableview UI...
    
    func setupUi() {
        
        listTableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: "CardTableViewCell")
        listTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListTableViewCell")
    }
    
    // MARK :- Making Post Service Call...
    
    func loadDynamicData()  {
        
        let url = "https://indb-frontend-dev.m2pfintech.com/pfm-sdk/get_merchant_budget"

        let parameters: [String: Any] = [
            "entity_id": "test","kit_number":1234,
            "next": [
                "skip" : 0,
                "limit" : 15
            ]
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { [self]
                    response in
                    switch (response.result) {
                    case .success( let JSON):
                        let response = JSON as! NSDictionary
                        self.listArray = response.value(forKey: "budgets") as! NSArray
                        
                        DispatchQueue.main.async {
                            self.listTableView.delegate = self
                            self.listTableView.dataSource = self
                            self.listTableView.reloadData()
                        }
                        
                        break
                    case .failure:
                        print(Error.self)
                    }
                }
    }
    
}

extension ViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
        if section == 0 {

            return 1
        }else {

            return listArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  indexPath.section == 0 {
            let cardCell = self.listTableView.dequeueReusableCell(withIdentifier: "CardTableViewCell") as! CardTableViewCell
            cardCell.delegate = self
            return cardCell
        }else  {

            let listCell = self.listTableView.dequeueReusableCell(withIdentifier: "ListTableViewCell") as! ListTableViewCell
            
            let listDic = listArray [indexPath.row] as! NSDictionary
            listCell.nameLbl.text = listDic.value(forKey: "merchant") as? String
            listCell.budgetIdLbl.text  = String ((listDic.value(forKey: "budget_id") as? Int)!)
            listCell.amountLbl.text = String((listDic.value(forKey: "budget_amount") as? Int)!)
            
            return listCell

        }
    }
    
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {

            return 170
        }else {

            return 120
        }
    }
}
extension ViewController: CardCellDelegate {
    
    func updateCVV(isSuccess: Bool) {
        authenticationWithTouchID()
        
    }
    
    // MARK :- BIOMETRIC Authentication Details
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"

        var authError: NSError?
        let reasonString = "To access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    self.bioMetricSuccess = "Success"
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: 0, section: 0)
                        let cardCell = self.listTableView.cellForRow(at: indexPath) as! CardTableViewCell
                        if self.isSuccess == true {
                            self.isSuccess = false
                            cardCell.switchAccess.isOn = false
                            cardCell.cvvLbl.text = "\("CVV") \("***")"
                        }else{
                            cardCell.switchAccess.isOn = true
                            cardCell.cvvLbl.text = "\("CVV") \(366)"
                            self.isSuccess = true
                        }
                    }
                    
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: 0, section: 0)
                        let cardCell = self.listTableView.cellForRow(at: indexPath) as! CardTableViewCell
                        cardCell.switchAccess.isOn = false
                        cardCell.cvvLbl.text = "\("CVV") \("***")"
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    UserDefaults.standard.setValue("Failure", forKey: "bioMetrciStatus")
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
                case LAError.biometryNotAvailable.rawValue:
                    message = "Authentication could not start because the device does not support biometric authentication."
                
                case LAError.biometryLockout.rawValue:
                    message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
                case LAError.biometryNotEnrolled.rawValue:
                    message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
                default:
                    message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
                case LAError.touchIDLockout.rawValue:
                    message = "Too many failed attempts."
                
                case LAError.touchIDNotAvailable.rawValue:
                    message = "TouchID is not available on the device"
                
                case LAError.touchIDNotEnrolled.rawValue:
                    message = "TouchID is not enrolled on the device"
                
                default:
                    message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}


