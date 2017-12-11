

import UIKit
import Toast_Swift
import SVProgressHUD

let Appname = "Demo"

class CommonFile: UIViewController
{

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


let appDelegate = UIApplication.shared.delegate as! AppDelegate
var arrCategory : NSMutableArray = []
var arrPlan : NSMutableArray = []
var strUserId = ""
var userInfoDict = NSDictionary()
var isSocialLogin: Bool = false
var isAccountVerified : Bool  = false

extension UIViewController {
    
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    func displayAlert(strMessage: String)
    {
        let alertController = UIAlertController(title: Appname, message: strMessage, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func showLoader(strMessage: String)
    {
        
        SVProgressHUD .show(withStatus: strMessage);
        SVProgressHUD.setBackgroundColor(UIColor.white);
        SVProgressHUD.setDefaultMaskType(.black);
        
    }
    
    func hideLoader()
    {
        SVProgressHUD .dismiss();
    }

    
    
    func addQuoteifExits(simpleString:NSString) -> NSString
    {
        var strTemp = simpleString
        
        if strTemp.contains("'")
        {
            strTemp = strTemp.replacingOccurrences(of: "'", with: "''") as NSString
        }
        
        return strTemp
        
    }
    
    
    func createImageNameFromDate() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        
        let resultStrDate = formatter.string(from: date)
        
        let strFinalName = "iOS-\(resultStrDate)"
        return strFinalName
    }
    
    func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.tintColor = UIColor(red:0.60, green:0.35, blue:0.75, alpha:1.0);
        
        
        let titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor(red:0.60, green:0.35, blue:0.75, alpha:1.0), NSAttributedStringKey.font: UIFont(name: "OpenSans-Bold", size: 16)!]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedStringKey : Any]
        
    }
    
    
    
    func setBackButtonBlank()
    {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func displayTost(strMessage: String)
    {
        self.view.makeToast(strMessage, duration: 3.0, position: .center)

    }
    
    func getDeviceTokenString() -> String
    {
        
        if (UserDefaults.standard.object(forKey: "DeviceToken") != nil)
        {
            let strToken = UserDefaults.standard.object(forKey: "DeviceToken") as! String
            return strToken
        }
        else
        {
            let strToken = ""
            return strToken
        }
    }
}

extension UIImageView
{
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    
}

extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x:0, y:0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x:0, y:0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension String {
    func appendingPathComponent(_ string: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(string).path
    }
}

extension Date {
    @nonobjc static var localFormatter: DateFormatter = {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateStyle = .medium
        dateStringFormatter.timeStyle = .medium
        return dateStringFormatter
    }()
    
    func localDateString() -> String
    {
        return Date.localFormatter.string(from: self)
    }
}



extension UIColor {
    
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}
func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState)
    {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
