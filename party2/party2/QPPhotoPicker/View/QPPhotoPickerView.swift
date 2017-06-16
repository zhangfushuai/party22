//
//  QPPhotoPicker.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.

import UIKit
import Photos
import AVKit
import AVFoundation

private let reuseIdentifier = "QPPickerCell"

enum UploadType {
    case pic
    case videl
    case audio
}

class QPPhotoPickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, PhotoPickerControllerDelegate, QPSinglePhotoPreviewViewDeleagte {
    
    var QPPhotos = [QPPhotoImageModel]()
    var controller: UIViewController?
    var collectionView: UICollectionView?
    var imagePickerController:UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        // 设置是否可以管理已经存在的图片或者视频
        imagePickerController.allowsEditing = true
        return imagePickerController
    }()
    var maxNum = 9
    
    var videourl:URL?
    var audiourl:URL?

    
    init(controller: UIViewController, frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.controller = controller
        createCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //设置collectionView
    func createCollectionView(){
        controller?.automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: PhotoPickerConfig.selectWidth,height: PhotoPickerConfig.selectWidth)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset = UIEdgeInsetsMake(
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing
        )
        self.addSubview(collectionView!)
    }
    

// MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if QPPhotos.count == maxNum {
            return QPPhotos.count
        }
        return QPPhotos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QPPickerCell
        var model: QPPhotoImageModel?
        if indexPath.row == QPPhotos.count {
            model = nil
        }else{
            model = QPPhotos[indexPath.row]
        }
        cell.setCell(model)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == QPPhotos.count {
            if QPPhotos.count == 0 {
                add()
            }else{
                addPic()
            }
        }else{
            eventPreview(index: indexPath.row)
        }
    }
    
    func initImagePickerController() {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        // 设置是否可以管理已经存在的图片或者视频
        self.imagePickerController.allowsEditing = true
    }
    
    func getImageFromPhotoLib(type:UIImagePickerControllerSourceType){
        self.imagePickerController.sourceType = type
        //判断是否支持相册
        let availabelMedia = UIImagePickerController.availableMediaTypes(for: .camera)!
        self.imagePickerController.mediaTypes = Array(arrayLiteral: availabelMedia[0])

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller?.present(self.imagePickerController, animated: true, completion:nil)
        }
    }
    
    func add() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler:{(alert) in
            self.takePicture()
        }))
        alert.addAction(UIAlertAction(title: "视频", style: .default, handler:{(alert) in
            self.takeCamera()
        }))
        alert.addAction(UIAlertAction(title: "相册", style: .default, handler:{(alert) in
            self.takeAlbum()
        }))
        alert.addAction(UIAlertAction(title: "录音", style: .default, handler:{(alert) in
            self.takeRecord()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        controller?.present(alert, animated: true, completion: nil)
    }
    func addPic() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler:{(alert) in
            self.takePicture()
        }))
        alert.addAction(UIAlertAction(title: "相册", style: .default, handler:{(alert) in
            self.takeAlbum()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        controller?.present(alert, animated: true, completion: nil)
    }

    
    func takePicture() {//拍照
        self.imagePickerController.delegate = self
        self.getImageFromPhotoLib(type: .camera)
    }
    func takeCamera() {//摄像
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .camera
        
        let availabelMedia = UIImagePickerController.availableMediaTypes(for: .camera)!
        self.imagePickerController.mediaTypes = Array(arrayLiteral: availabelMedia[1])
        self.imagePickerController.videoMaximumDuration = 10
        
        //判断是否支持相册
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller?.present(self.imagePickerController, animated: true, completion:nil)
        }

        
        
    }
    func takeAlbum() {//相册
        let vc = QPPhotoPickerViewController(type: PageType.AllAlbum)
        vc.imageSelectDelegate = self
        //最大照片数量
        vc.imageMaxSelectedNum = maxNum
        vc.alreadySelectedImageNum = QPPhotos.count
        controller?.present(vc, animated: true, completion: nil)
    }
    func takeRecord() {//录音
        
    }
    
    
    func updateMovieUI(){
        
        self.collectionView?.isHidden = true
        
        let movieIV = UIImageView(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width-40, height: 200))
        self.addSubview(movieIV)
        movieIV.image = self.getVideoImage(self.videourl!)
        movieIV.isUserInteractionEnabled = true
        
        let playIV = UIImageView(frame: CGRect(x: (movieIV.bounds.width-100)/2, y: (movieIV.bounds.height-100)/2, width: 100, height: 100))
        playIV.image = #imageLiteral(resourceName: "video-play")
        movieIV.addSubview(playIV)
        playIV.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(playMovie))
        playIV.addGestureRecognizer(ges)
        
        
    }
    
    func updateRecordUI(){
        
    }

    
    func playMovie(){
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: self.videourl!)

        self.controller?.present(playerViewController, animated: true, completion: {
            playerViewController.player?.play()
        })
        
        
        
        
    }
    
    
    
    
    
    //添加照片的协议方法
    func onImageSelectFinished(images: [PHAsset]) {
        QPPhotoDataAndImage.getImagesAndDatas(photos: images) { (array) in
            for model in array!{
                self.QPPhotos.append(model)
            }
            self.collectionView?.reloadData()
        }
    }
    
    
    //查看大图
    func eventPreview(index: Int){
        let preview = QPSinglePhotoPreviewViewController()
        let nav = UINavigationController.init(rootViewController: preview)
        let data = self.getModelExcept()
        preview.selectImages = data
        preview.delegate = self
        preview.currentPage = index
        
        let animation = CATransition.init()
        animation.duration = 0.5
        animation.subtype = kCATransitionFromRight
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
        controller?.present(nav, animated: false, completion: nil)
    }
    
    //查看大图后的协议方法
    func removeElement(element: QPPhotoImageModel?) {
        if let current = element {
            self.QPPhotos = self.QPPhotos.filter({$0 != current})
        }
        collectionView?.reloadData()
    }
    
    private func getModelExcept()->[QPPhotoImageModel]{
        var newModels = [QPPhotoImageModel]()
        for i in 0..<self.QPPhotos.count {
            let item = self.QPPhotos[i]
            newModels.append(item)
        }
        return newModels
    }
}

extension QPPhotoPickerView: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let type:String = (info[UIImagePickerControllerMediaType]as!String)
        if type == "public.image" {
            let bigimg = info[UIImagePickerControllerOriginalImage] as? UIImage
            let imgData = UIImageJPEGRepresentation(bigimg!, 0.5)
            let smallImage = info[UIImagePickerControllerEditedImage] as? UIImage
            let model = QPPhotoImageModel()
            model.bigImage = bigimg
            model.imageData = imgData
            model.smallImage = smallImage
            self.QPPhotos.append(model)
            self.collectionView?.reloadData()
            picker.dismiss(animated: true, completion: { 
                self.imagePickerController.delegate = nil
            })
        } else if type == "public.movie" {
            
            DispatchQueue.main.async(){

                picker.dismiss(animated: true, completion: {
                    self.imagePickerController.delegate = nil
                })
                
                
                
//                let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL!
//                let videoPath = videoURL!.relativePath;
//
//                let player = AVPlayer(url: videoURL! as URL)
//                let playerViewController = AVPlayerViewController()
//                playerViewController.player = player
//                self.controller?.present(playerViewController, animated: true, completion: { 
//                    player.play()
//                })
                
                
                let url = info[UIImagePickerControllerMediaURL] as? NSURL

                self.videourl = url as URL?
                
                self.updateMovieUI()

            
            
            }

            
            

            
            
            
            
            

            
        }
        
        
    }
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:nil)
    }
    
    func getVideoImage(_ videoUrl: URL) -> UIImage? {
        //  获取截图
        let videoAsset = AVURLAsset(url: videoUrl)
        let cmTime = CMTime(seconds: 1, preferredTimescale: 10)
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        if let cgImage = try? imageGenerator.copyCGImage(at: cmTime, actualTime: nil) {
            let image = UIImage(cgImage: cgImage)
            return image
        } else {
            print("获取缩略图失败")
        }
        
        return nil
    }

    
    
}
