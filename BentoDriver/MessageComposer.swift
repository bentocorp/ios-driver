//
//  MessageComposer.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/21/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import MessageUI

public class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    let phoneDigitsString: String
    let textMessageRecipients: [String]
    
    init(phoneString: String) {
        // get only digits from phone string
        let phoneArray =  phoneString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        phoneDigitsString = phoneArray.joinWithSeparator("")
        textMessageRecipients = ["\(phoneDigitsString)"]
    }
    
    public func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    public func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = ["\(phoneDigitsString)"]
//        messageController.body = ""
        
        return messageController
    }
    
    public func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        // TODO: change to switch statement
        if (result.rawValue == MessageComposeResultCancelled.rawValue) {
            NSLog("Message was cancelled.");
        }
        else if (result.rawValue == MessageComposeResultFailed.rawValue) {
            let warningAlert = UIAlertView();
            warningAlert.title = "Error";
            warningAlert.message = "Failed to send SMS!";
            warningAlert.delegate = nil;
            warningAlert.show();
            NSLog("Message failed.");
        }
        else {
            NSLog("Message was sent.");
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil);
    }
}
