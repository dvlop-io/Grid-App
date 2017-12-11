//
//  ViewController.swift
//  Grid
//
//  Created by Bryan Lloyd Anderson on 10/28/15.
//  Copyright © 2015 Bryan Lloyd Anderson. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
import SafariServices

class ViewController: UIViewController, CompareVersionable, WKNavigationDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    var webKitView = WKWebView()
    
    @IBOutlet weak var webSubView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLayoutSubviews() {
        
        
        // view.addConstraint(heightConstraint) // also works
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webKitView)
        
        
        webKitView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        webKitView.allowsBackForwardNavigationGestures = true
        
        
        
        progressView.progress = 0
        
        progressView.progressTintColor = UIColor(red:0.37, green:0.74, blue:0.00, alpha:1.0)
        progressView.trackTintColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
        
        webKitView.translatesAutoresizingMaskIntoConstraints = false
        webKitView.navigationDelegate = self
        
        let horizontalConstraint = NSLayoutConstraint(item: webKitView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: webKitView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
        
        let widthConstraint = NSLayoutConstraint(item: webKitView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: webKitView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: webSubView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        view.addConstraint(heightConstraint)
        
        
        if let urlString = UserDefaults.standard.object(forKey: "urlString") as? String {
            let url = URL(string: "http://grid.lgcypower.com")
            let requestObj = URLRequest(url: url!)
            webKitView.load(requestObj)
        } else {
            let url = URL(string: "http://grid.lgcypower.com")
            let requestObj = URLRequest(url: url!)
            webKitView.load(requestObj)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", for: .valueChanged)
        let refreshFrame = refreshControl.frame
        refreshControl.frame = CGRect(x: refreshFrame.origin.x - 100, y: refreshFrame.origin.y + 100, width: refreshFrame.size.width, height: refreshFrame.size.height)
        refreshControl.tintColor = UIColor.white
        refreshControl.alpha = 0.7
        //        webKitView.scrollView.addSubview(refreshControl)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.resetAnimation), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkVersion()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        
        
    }
    
    func resetAnimation() {
        DispatchQueue.main.async(execute: { () -> Void in
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 0.01)
                self.progressView.transform = transform
                
            }, completion: { (completed) -> Void in
                
                self.progressView.setProgress(0, animated: false)
            })
        })
    }
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.31, blue:0.50, alpha:1.0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back to Grid", style: .plain, target: nil, action: nil)
        
        
        //        webKitView.scrollView = UIwebKitView.scrollView(frame: view.bounds, style: .Plain)
        //        webKitView.scrollView.dataSource = self
        //        webKitView.scrollView.delegate = self
        webKitView.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        webKitView.scrollView.separatorColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 231/255.0, alpha: 1.0)
        webKitView.scrollView.backgroundColor = UIColor.clear
        //        view.addSubview(webKitView.scrollView)
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        webKitView.scrollView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self?.webKitView.scrollView.dg_stopLoading()
                self?.handleRefresh()
            })
            }, loadingView: loadingView)
        let refreshFillColor = UIColor(red:0.15, green:0.38, blue:0.60, alpha:1.0)
        webKitView.scrollView.dg_setPullToRefreshFillColor(refreshFillColor)
        webKitView.scrollView.dg_setPullToRefreshBackgroundColor(webKitView.scrollView.backgroundColor!)
    }
    
    deinit {
        webKitView.scrollView.dg_removePullToRefresh()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func handleRefresh() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let url = self.webKitView.url else { return }
        let requestObj = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        //        webKitView.reload()
        webKitView.load(requestObj)
        //        sender.endRefreshing()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            
            getProgress()
        }
    }
    
    
    func getProgress() {
        let progress = self.webKitView.estimatedProgress
        
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.progressView.setProgress(Float(progress), animated: true)
            let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 3)
            self.progressView.transform = transform
            print(self.progressView.transform.a)
            print(self.progressView.transform.d)
        })
        
        print(progress)
        
    }
    var targetURL: URL?
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print(navigationAction)
        if navigationAction.targetFrame != nil {
            guard let url = navigationAction.request.url else { return }
            let urlString = String(describing: url)
            UserDefaults.standard.set(urlString, forKey: "urlString")
            
            print(url)
            if url != URL(string: "http://grid.lgcypower.com/") {
                if  url.description.lowercased().range(of: "mailto:") != nil || url.description.lowercased().range(of: "maps://") != nil || url.description.lowercased().range(of: "tel:") != nil || url.description.lowercased().range(of: "sms:") != nil{
                    
                    //                print(url.scheme, url.)
                    if  (url.description.lowercased().range(of: "mailto:") != nil) {
                        launchEmailComposeViewController("\(url)")
                        
                    }
                    
                    if  (url.description.lowercased().range(of: "sms:") != nil) {
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
            UserDefaults.standard.set(nil, forKey: "urlString")
            
            return
        }
        decisionHandler(.allow)
    }
    
    var timer: Timer?
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.bringSubview(toFront: progressView)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 0.1)
        self.progressView.transform = transform
        getProgress()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        finishAnimatingProgress()
        
        
        //        self.webKitView.evaluateJavaScript("document.getElementById('UserEmail').value = 'Hello Result';") { (data, error) -> Void in
        
        //            print(data, error)
        //        }
        //        self.webKitView.stringByEvaluatingJavaScriptFromString("document.getElementById('result').value = 'Hello Result';")
        
        
        
    }
    
    
    
    func finishAnimatingProgress() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.progressView.setProgress(1, animated: true)
        }, completion: { (completed) -> Void in
            
            UIView.animate(withDuration: 1, animations: { () -> Void in
                
                
                let transform: CGAffineTransform = CGAffineTransform(scaleX: 1, y: 0.01)
                self.progressView.transform = transform
                
                
            }, completion: { (completed) -> Void in
                self.progressView.setProgress(0, animated: true)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TargetBlank" {
            if let destinationVC = segue.destination as? TargetBlankViewController {
                destinationVC.targetURL = self.targetURL
            }
        }
    }
}

