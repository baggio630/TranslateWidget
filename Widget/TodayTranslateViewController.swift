//
//  TodayTranslateViewController.swift
//  Widget
//
//  Created by Joey on 2017/2/28.
//  Copyright © 2017年 Joey. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON
import Alamofire
import SnapKit
import CryptoSwift


class TodayTranslateViewController: UIViewController, NCWidgetProviding {
        
    var tranButton = UIButton()
    var returnButton = UIButton()
    var addToWordBookButton = UIButton()
    var displayModleChange = Bool()
    var maxHieghtSize = CGSize(width: 0, height: 100)
    
    var display = UILabel()
    
    //颜色
    func color(_ red:CGFloat, _ green:CGFloat, _ blue:CGFloat, _ alpha:CGFloat) -> UIColor {
        return UIColor( red: red/255, green: green/255, blue: blue/255, alpha: alpha )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        returnButton.isHidden = true
        display.isHidden = true
        addToWordBookButton.isHidden = true
        
        // 翻译按钮
        self.view.addSubview(tranButton)
        tranButton.addTarget(self, action:#selector(copyTrans), for:.touchUpInside)
        tranButton.setTitle("翻译", for:.normal)
        tranButton.setTitleColor(color(51, 51, 51, 1), for: .normal)
        tranButton.setTitleColor(color(51, 51, 51, 0.5), for: .highlighted)
        tranButton.backgroundColor = (color(0, 0, 0, 0.03))
        tranButton.layer.borderWidth = 0.5
        tranButton.layer.borderColor = (color(0, 0, 0, 0.12)).cgColor
        tranButton.layer.cornerRadius = 4
        
        tranButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.top.equalTo(35)
        }
        
        // 翻译label
        self.view.addSubview(display)
        display.backgroundColor = (UIColor.clear)
        display.textAlignment = NSTextAlignment.center
        display.numberOfLines = 0
        display.font = UIFont.systemFont(ofSize: 20.0)
        
        display.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(20)
            make.width.equalTo(self.view.bounds.size.width - 40)
        }
        
        // 添加至单词本按钮
        self.view.addSubview(addToWordBookButton)
        addToWordBookButton.setTitle("记录", for:.normal)
        addToWordBookButton.setTitleColor(color(51, 51, 51, 1), for: .normal)
        addToWordBookButton.setTitleColor(color(51, 51, 51, 0.5), for: .disabled)
        addToWordBookButton.backgroundColor = (color(0, 0, 0, 0.03))
        addToWordBookButton.layer.borderWidth = 0.5
        addToWordBookButton.layer.borderColor = (color(0, 0, 0, 0.12)).cgColor
        addToWordBookButton.layer.cornerRadius = 4
        
        addToWordBookButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(-50)
            make.left.equalTo(display.snp.centerX).offset(5)
            make.top.equalTo(display.snp.bottom).offset(10)
        }
        
        // 返回按钮
        self.view.addSubview(returnButton)
        returnButton.addTarget(self, action:#selector(reTrans), for:.touchUpInside)
        returnButton.setTitle("返回", for:.normal)
        returnButton.setTitleColor(color(51, 51, 51, 1), for: .normal)
        returnButton.backgroundColor = (color(0, 0, 0, 0.03))
        returnButton.layer.borderWidth = 0.5
        returnButton.layer.borderColor = (color(0, 0, 0, 0.12)).cgColor
        returnButton.layer.cornerRadius = 4
        
        returnButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(50)
            // make.right.equalTo(-50)
            make.right.equalTo(addToWordBookButton.snp.left).offset(-10)
            make.top.equalTo(display.snp.bottom).offset(10)
            //make.bottom.equalTo(-20)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func copyTrans(_ sender: Any) {
        if let pasteBoard = UIPasteboard.general.string {
            tranButton.isHidden = true
            returnButton.isHidden = false
            display.isHidden = false
            addToWordBookButton.isEnabled = false
            addToWordBookButton.isHidden = false
            getExplains(getBaiduApiUrl(pasteBoard))
        } else {
            tranButton.isHidden = true
            returnButton.isHidden = false
            display.isHidden = false
            addToWordBookButton.isEnabled = false
            addToWordBookButton.isHidden = false
            display.text = "剪贴板为空"
        }
    }
    
    func reTrans(_ sender: Any) {
        tranButton.isHidden = false
        returnButton.isHidden = true
        display.isHidden = true
        addToWordBookButton.isHidden = true
        display.text = nil
        tranButton.setTitle("翻译", for:.normal)
        maxHieghtSize = CGSize(width: 0, height: 100)
        self.preferredContentSize = maxHieghtSize
    }
    
    // 获取百度翻译url
    func getBaiduApiUrl(_ query:String) -> String {
        let baiduId = "20160222000013020"
        let key = "Rb9zymWhs4iOTwsroYlc"
        let salt = "14356610214"
        let textUtf8 = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print("utf8: \(textUtf8)")
        let sign = baiduId + query + salt + key
        let signMd5 = sign.md5()
        let baiduApiUrl = "https://fanyi-api.baidu.com/api/trans/vip/translate?q=\(textUtf8)&from=auto&to=zh&appid=20160222000013020&salt=14356610214&sign=\(signMd5)"
        print("\(baiduApiUrl)")
        return baiduApiUrl
    }
    
    // 获取谷歌翻译url
    func getGoogleTranslateApiUrl(_ query:String) -> String {
        let googleKey = "AIzaSyBumRMNSR5cWezLMp3R7NHfpq_yuyyUG6g"
        let textUtf8 = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print("utf8: \(textUtf8)")
        let googleTranslateApiUrl = "https://www.googleapis.com/language/translate/v2?q=\(textUtf8)&target=zh-CN&cid=123&format=text&source=en&fields=translations&key=\(googleKey)"
        print("谷歌url：\(googleTranslateApiUrl)")
        return googleTranslateApiUrl
    }
    
    // 判断展开收起状态下高度
    func hieghtCalculate(_ getExplains:String) {
        display.text = getExplains
        let maxHiegh = self.getLabHeigh(labelStr: getExplains, font: UIFont.systemFont(ofSize: 20.0))
        let HieghtSize = CGSize(width: 0, height: maxHiegh + 100)
        print("翻译后高度\(HieghtSize)")
        
        if (self.extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.compact) {
            print("@收起状态")
            maxHieghtSize = HieghtSize
            print("@收起状态 传输展开状态高度为：\(maxHieghtSize)")
        }
        
        if (self.extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.expanded ){
            self.preferredContentSize = HieghtSize
            print("@展开状态：\(HieghtSize)")
        }
    }
    
    // 谷歌json解析
    func googleJson(_ jsonData:Data) -> String {
        var explains = String()
        let translateResult = JSON(data: jsonData)
        print("Data: \(translateResult)")
        if let explainsArray = translateResult["data"]["translations"].array {
            print("翻译数组:\(explainsArray)")
            if let explains = explainsArray[0]["translatedText"].string {
                print("翻译1:\(explains)")
                self.hieghtCalculate(explains)
            }
        } else {
            explains = "无结果"
            print("无结果")
        }
        return explains
    }
    
    // 百度翻译json解析
    func baiduJson(_ jsonData:Data) -> String {
        var explains = String()
        let translateResult = JSON(data: jsonData)
        print("Data: \(translateResult)")
        if let explainsArray = translateResult["trans_result"].array {
            print("翻译数组:\(explainsArray)")
            if let explains = explainsArray[0]["dst"].string {
                print("翻译1:\(explains)")
                self.hieghtCalculate(explains)
            }
        } else {
            explains = "无结果"
            print("无结果")
        }
        return explains
    }
    
    // 请求url获取返回数据
    func getExplains(_ searchUrl:String) {
        Alamofire.request(searchUrl).response { response in
            if let translateData = response.data {
                _ = self.baiduJson(translateData)
                // Swift 3.0 中方法的返回值必须有接收否则会报警告，但是有些情况下确实不需要使用返回值可以使用"_"接收来忽略返回值。
            }
        }
    }
    
    // 计算label高度
    func getLabHeigh(labelStr:String,font:UIFont) -> CGFloat {
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize(width: self.view.bounds.size.width - 40, height: 900)
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        return strSize.height
    }
    
    // 监控 Widget 展开收起按钮
    func widgetActiveDisplayModeDidChange( _ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = CGSize(width: 0, height: 100)
            print("@@收起了")
        }else {
            self.preferredContentSize = maxHieghtSize
            print("@@\(maxHieghtSize)")
            print("@@展开了")
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
