//
//  TargetBlankViewController.swift
//  Grid
//
//  Created by Bryan Lloyd Anderson on 11/18/15.
//  Copyright © 2015 Bryan Lloyd Anderson. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
import SafariServices

class TargetBlankViewController: UIViewController, CompareVersionable, WKNavigationDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate  {
    
    
    var targetURL: URL?
    
    var targetWebKitView = WKWebView()
    
    @IBOutlet weak var webSubView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLayoutSubviews() {
        
        
        // view.addConstraint(heightConstraint) // also works
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(targetWebKitView)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        targetWebKitView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        targetWebKitView.allowsBackForwardNavigationGestures = true
        
        
        progressView.progress = 0
        
        progressView.progressTintColor = UIColor(red:0.37, green:0.74, blue:0.00, alpha:1.0)
        progressView.trackTintColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
        
        targetWebKitView.translatesAutoresizingMaskIntoConstraints = false
        targetWebKitView.navigationDelegate = self
        
        let horizontalConstraint = NSLayoutConstraint(item: targetWebKitView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: targetWebKitView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
        
        let widthConstraint = NSLayoutConstraint(item: targetWebKitView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: targetWebKitView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        view.addConstraint(heightConstraint)
        
        
        
        guard let targetURL = targetURL else { return }
        let requestObj = URLRequest(url: targetURL)
        targetWebKitView.load(requestObj)
        
        
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", for: .valueChanged)
        let refreshFrame = refreshControl.frame
        refreshControl.frame = CGRect(x: refreshFrame.origin.x - 100, y: refreshFrame.origin.y + 100, width: refreshFrame.size.width, height: refreshFrame.size.height)
        refreshControl.tintColor = UIColor.white
        refreshControl.alpha = 0.7
        //        targetWebKitView.scrollView.addSubview(refreshControl)
        
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkVersion()
    }
    
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.31, blue:0.50, alpha:1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        targetWebKitView.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetWebKitView.scrollView.backgroundColor = UIColor.clear
        
        
    }
    
    deinit {
        self.targetWebKitView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.targetWebKitView.navigationDelegate = nil
        self.targetWebKitView.uiDelegate = nil
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
    func handleRefresh() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let url = self.targetWebKitView.url else { return }
        let requestObj = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        //        targetWebKitView.reload()
        targetWebKitView.load(requestObj)
        //        sender.endRefreshing()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            
            getProgress()
        }
    }
    
    
    
    func getProgress() {
        let progress = self.targetWebKitView.estimatedProgress
        
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.progressView.setProgress(Float(progress), animated: true)
            let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 3)
            self.progressView.transform = transform
            print(self.progressView.transform.a)
            print(self.progressView.transform.d)
        }) 
        
        print(progress)
        
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print(navigationAction)
        if navigationAction.targetFrame != nil {
            guard let url = navigationAction.request.url else { return }
            
            if url != URL(string: "http://grid.lgcypower.com/") {
                if  url.description.lowercased().range(of: "mailto:") != nil || url.description.lowercased().range(of: "maps://") != nil || url.description.lowercased().range(of: "tel:") != nil || url.description.lowercased().range(of: "sms:") != nil{
                    
                   
                    
                    if  (url.description.lowercased().range(of: "mailto:") != nil) {
                        launchEmailComposeViewController("\(url)")
                        
                    }
                    
                    if  (url.description.lowercased().range(of: "sms:") != nil) {
                        //TODO: Remove sms prepend
                        launchMessageComposeViewController("\(url)")
                        
                    }
                    
                    if  (url.description.lowercased().range(of: "tel:") != nil) {
                        UIApplication.shared.openURL(url)
                        
                        
                    }
                    if (url.description.lowercased().range(of: "maps://") != nil) {
                        UIApplication.shared.openURL(url)
                    }
                } else {
                    if url == URL(string: "itms-services://?action=download-manifest&url=https://grid.lgcypower.com/apps/grid/manifest.plist") {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            
        } else {
            decisionHandler(.cancel)
            guard let url = navigationAction.request.url else { return }
            
            
            self.targetURL = url
            self.performSegue(withIdentifier: "TargetBlank", sender: self)
            
            return
        }
        decisionHandler(.allow)
    }
    
    //    var timer: NSTimer?
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.bringSubview(toFront: progressView)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 0.1)
        self.progressView.transform = transform
        getProgress()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if let url = self.targetWebKitView.url {
            let urlString = String(describing: url)
            print(urlString)
            UserDefaults.standard.set(urlString, forKey: "urlString")
        }
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.progressView.setProgress(1, animated: true)
            }, completion: { (completed) -> Void in
                
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    
                    
                    let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 0.01)
                    self.progressView.transform = transform
                    
                    
                    }, completion: { (completed) -> Void in
                        self.progressView.setProgress(0, animated: true)
                        
                        //                      self.progressView.progress = 0
                        
                }) 
        }) 
        
        
    }
    
    
    func launchMessageComposeViewController(_ recipientNumber: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            messageVC.recipients = [recipientNumber]
            messageVC.body = ""
            self.present(messageVC, animated: true, completion: nil)
        }
        else {
            print("User hasn't setup Messages.app")
        }
    }
    
    // this function will be called after the user presses the cancel button or sends the text
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func launchEmailComposeViewController(_ toRecipient: String) {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("")
        picker.setMessageBody("", isHTML: true)
        picker.setToRecipients([toRecipient])
        
        
        present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
