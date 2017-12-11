//
//  SocialView.swift
//  BoardsInterview
//
//  Created by Maulik Vekariya on 12/8/17.
//  Copyright © 2017 Maulik Vekariya. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SDWebImage

class SocialView: UIViewController,UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate
{

    var arrData : NSMutableArray = []
    var nextPageURL = ""
    @IBOutlet var seg: UISegmentedControl!
    @IBOutlet var tblList: UITableView!
    var arrFilteredData : NSMutableArray = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Messaging"
        let finalUrl = "\(appDelegate.baseURL)/get_messages"
        self.getMessages(url: finalUrl)
        
        let attr = NSDictionary(object: UIFont(name: "OpenSans-Bold", size: 16)!, forKey: NSAttributedStringKey.font as NSCopying)
        seg.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        
        self.tblList.register(UINib(nibName: "SbutCell", bundle: nil), forCellReuseIdentifier: "Cell_sbut")
        self.tblList.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "Cell_twitter")

        self.tblList.rowHeight = UITableViewAutomaticDimension
        
        let tblView =  UIView(frame: CGRect.zero)
        self.tblList.tableFooterView = tblView
        self.tblList.tableFooterView?.isHidden = true;
        self.tblList.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentChanged(_ sender: Any)
    {
        if seg.selectedSegmentIndex == 1
        {
            let pred = NSPredicate(format: "social_type = %@", "twitter")
            let arrTemp = self.arrData.filtered(using: pred)
            self.arrFilteredData.removeAllObjects()
            self.arrFilteredData.addObjects(from: arrTemp)
        }
        else if seg.selectedSegmentIndex == 2
        {
            let pred = NSPredicate(format: "social_type = %@", "SBUT")
            let arrTemp = self.arrData.filtered(using: pred)
            self.arrFilteredData.removeAllObjects()
            self.arrFilteredData.addObjects(from: arrTemp)
        }
        self.tblList.reloadData()
    }
    
    func getMessages(url: String)
    {
        
        AFWrapper.requesting(methodRequest: .get, URLString: url, parameters: nil, onSuccess:
            {
                (response) in
                
                debugPrint(response)
                
                let dictResponse = response as! NSDictionary
                
                if (dictResponse.object(forKey: "data") != nil)
                {
                    let arr = dictResponse.object(forKey: "data") as! NSArray
                    self.arrData .addObjects(from: arr as! [Any])
                    self.tblList.reloadData()
                }
                
                if (dictResponse.object(forKey: "next_page_url") != nil)
                {
                    let str = dictResponse.object(forKey: "next_page_url") as! String
                    
                    if str.isEmpty
                    {
                        self.nextPageURL = ""
                    }
                    else
                    {
                        self.nextPageURL = dictResponse.object(forKey: "next_page_url") as! String
                    }
                }
                
                
        }
            , onFailure: {
                (error) in
                print(error);
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if seg.selectedSegmentIndex == 0
        {
            return self.arrData.count
        }
        else
        {
            return self.arrFilteredData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var dictVisible = arrData[indexPath.row] as! NSDictionary
        
        if seg.selectedSegmentIndex == 0
        {
            if indexPath.row == arrData.count - 8
            {
                self.getMessages(url: nextPageURL)
            }
        }
        else
        {
            dictVisible = arrFilteredData[indexPath.row] as! NSDictionary
        }
            
        if dictVisible.object(forKey: "social_type") as! String == "twitter"
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_twitter",for: indexPath) as! SocialCell
            
            cell.selectionStyle = .none
            
            cell.lblTitle.delegate = self
            cell.lblTitle.enabledTextCheckingTypes = NSTextCheckingAllTypes
            
            cell.lblLink.delegate = self
            cell.lblLink.enabledTextCheckingTypes = NSTextCheckingAllTypes
            cell.lblLink.linkAttributes = [kCTForegroundColorAttributeName : UIColor(red:0.00, green:0.82, blue:1.00, alpha:1.0)]
            
            let strName = dictVisible.object(forKey: "name") as! String
            let strScreenName = dictVisible.object(forKey: "screenName") as! String

            cell.lblTitle.text = "\(strName) @\(strScreenName)"
            cell.lblTitle.linkAttributes = [kCTForegroundColorAttributeName : UIColor(red:0.68, green:0.66, blue:0.66, alpha:1.0), kCTFontAttributeName : UIFont(name: "OpenSans", size: 13)!]
            
            let range = NSMakeRange(strName.count+1, strScreenName.count+1)
            let url = URL(string: "twitter:///user?screen_name=@\(strScreenName)")
            cell.lblTitle.addLink(to: url, with: range)
            cell.lblLink.text = dictVisible.object(forKey: "tweet") as? String
            cell.lblDate.text = dictVisible.object(forKey: "Original_Post_DateTime") as? String
            cell.lblVia.text = "via Twitter"

            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_sbut",for: indexPath) as! SbutCell
            cell.selectionStyle = .none
            
            cell.lblTitle.delegate = self
            cell.lblTitle.enabledTextCheckingTypes = NSTextCheckingAllTypes
            cell.lblTitle.linkAttributes = [kCTForegroundColorAttributeName : UIColor(red:0.00, green:0.82, blue:1.00, alpha:1.0)]
            
            let strName = dictVisible.object(forKey: "message") as! String
            
            cell.lblTitle.text = "\(strName)"
            
            cell.imgMessage.setShowActivityIndicator(true)
            cell.imgMessage.setIndicatorStyle(.gray)
            
            let strImg = dictVisible.object(forKey: "imageurl") as! String
            
            if !strImg.isEmpty
            {
                cell.imgMessage.sd_setImage(with: URL(string: strImg), placeholderImage: nil, options: .refreshCached)
            }
            
            cell.imgMessage.contentMode = .scaleAspectFit
            cell.imgMessage.clipsToBounds = true
            
            cell.lblDate.text = dictVisible.object(forKey: "Original_Post_DateTime") as? String
            cell.lblVia.text = "via SBUT"
            
            return cell
        }
        
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        let dictVisible = arrData[indexPath.row] as! NSDictionary
        
        if dictVisible.object(forKey: "social_type") as! String == "twitter"
        {
            return 108
        }
        else
        {
            return 296
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!)
    {
        UIApplication.shared.openURL(url)
    }
}
