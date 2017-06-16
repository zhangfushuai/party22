//
//  UploadViewController.swift
//  party2
//
//  Created by shuai on 2017/5/15.
//  Copyright © 2017年 chinsoft. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {
    var picker: QPPhotoPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        
        let backbtn = UIButton(frame: CGRect(x: 10, y: 20, width: 40, height: 30))
        view.addSubview(backbtn)
        backbtn.backgroundColor = .red
        backbtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        backbtn.setTitle("返回", for: .normal);

        
        QPPicker()
        
        let btn = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 40))
        view.addSubview(btn)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(upLoadData), for: .touchUpInside)
        btn.setTitle("上传", for: .normal);
        
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    //初始化并添加
    /* 第一个参数，当前控制器
     * 第二个参数，照片选择器的frame
     */
    func QPPicker(){
        picker = QPPhotoPickerView.init(controller: self, frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-64))
        //选取照片最大数量
        picker?.maxNum = 9
        self.view.addSubview(picker!)
    }
    //上传
    func upLoadData(){
        var dataArray = [Data]()
        if let _ = picker?.videourl {
            let data = try? Data(contentsOf: (picker?.videourl!)!)
            if let _ = data {
                dataArray.append(data!)
            }
        
        }
        
        for model in (picker?.QPPhotos)! {
            dataArray.append(model.imageData!)
        }
        //上传Data数组
        self.view.makeToastActivity(.center)
        CCore.uploadDatas(dataArray) { (Attachment) in
           self.view.hideToastActivity()
            self.view.makeToast("上传成功", duration: 10, position:.center)
//            UIAlertView(title: nil, message: "上传成功", delegate: nil, cancelButtonTitle: "确定").show()

            print(Attachment)
            
        }
        
        
        
        
    }

    

    
}
