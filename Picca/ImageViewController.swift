//
//  imageViewController.swift
//  Picca
//
//  Created by Rens Gingnagel on 08/12/2017.
//  Copyright © 2017 Rens Gingnagel. All rights reserved.
//

import UIKit
import Disk
import Firebase
import FirebaseAuth


class imageViewController: UIViewController {


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //URL containing the image
//    let URL_IMAGE = URL(string: "https://images.unsplash.com/36/rv1BIw0tSKi0xLtGrpR0_TE3_0185.jpg?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=1ce48d2f902c78d8793199668e7592f1")
    
    @IBOutlet weak var uiImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var photographerLabel: UILabel!
    

//    var user: ourUser!
    
    var oldImageData: Photo?
    
    // Shadow and Radius for Circle Button

    @IBAction func likeButtonPressed(_ sender: Any) {
        setNewPhoto(like: true)
        
        print("Like button pressed!")
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        setNewPhoto(like: false)
        print("Dislike button pressed!")
    }
    
    @IBAction func closePressed(_ sender: Any) {
        print("Close button pressed")
        infoView.isHidden = true
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        print("Info Button Pressed")
        infoView.isHidden = false
    }
    
    struct Urlstruct: Codable {
        var raw: String?
        var full: String?
        var regular: URL?
        var small: String?
        var thumb: String?
    }
    struct User: Codable {
        var id: String?
        var username: String?
        var name: String?
    }
    
    struct Photo: Codable {
        var id: String?
        var description: String?
        var urls: Urlstruct?
        var user: User?
    }
    
    struct imageData{
        var description: String?
        var author: String?
        var id: String?
    }

    @IBOutlet weak var infoView: UIStackView!

    
    func callAPI() -> Photo?{
        let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=d045418f560e79b6e822ec2329ebc03de8bdadd2e180ce9044b4e663e3e25159&orientation=landscape&featured=True")!
//        let url = URL(string: "https://blabla")!
        
        
        guard let data = try? Data(contentsOf: url) else{return nil}
        let jsonDec = JSONDecoder()
        guard let result = try? jsonDec.decode(Photo.self, from: data) else{ return nil}
        //    print(result)
//        guard let photoDescription = result.description, let photoUrl = result.urls?.regular else {return nil}
//        print(photoUrl)
//        print(photoDescription)

        return result
        
    }
    
    func setNewPhoto(like: Bool){
        
        if(like){
            let likesRef = Database.database().reference(withPath: "likes")
            let reference  = likesRef.childByAutoId()
            if let oldImageID = oldImageData?.id{
                reference.setValue(oldImageID)
            }
            
           
        }
        
        
        guard let CurrentImageData = callAPI() else {
            print("There is no Image")
            setNewPhoto(like: like)
            return
        }
    
        guard let CurrentImageURL = CurrentImageData.urls?.regular else {
            print("There is no Image URL")
            setNewPhoto(like: like)
            return
        }
        
        oldImageData = CurrentImageData
        
        if let CurrentImagePhotographer = CurrentImageData.user?.username {
            photographerLabel.text = CurrentImagePhotographer
        } else {
            print("There is no photographer")
        }
        
        if let CurrentImageDescription = CurrentImageData.description {
            descriptionLabel.text = CurrentImageDescription
        } else {
            print("There is no description.")
        }
        
        
        if let CurrentImageID = CurrentImageData.id {
            IDLabel.text = CurrentImageID
        } else {
            print("There is no id")
        }
        
        
        
        let session = URLSession(configuration: .default)
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: CurrentImageURL) { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    
                    //checking if the response contains an image
                    if let imageData = data {
                        
                        //getting the image
                        let image = UIImage(data: imageData)
                        
//                        do{
//                            try Disk.save(image, to: .caches, as: "currentImage.png")
//                            try Disk.save(CurrentImageData, to: .caches, as: "currentImageData.json")
//                            //            let retrieved = try Disk.retrieve("currentImage.json", from: .caches, as: Photo.self)
//                            //            print(retrieved)
//                        } catch{
//                            print("Saving image to disk failed.")
//                        }
                        
                        //displaying the image
                        DispatchQueue.main.async() { self.uiImageView.image = image }
                        
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        }
        
        //starting the download task
        getImageFromUrl.resume()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        infoView.isHidden = true
//        do{
//            try Disk.save(image, to: .caches, as: "currentImage.json")
//            //            let retrieved = try Disk.retrieve("currentImage.json", from: .caches, as: Photo.self)
//            //            print(retrieved)
//        } catch{
//            print("Saving image to disk failed.")
//        }
        
        setNewPhoto(like: false)
        
//        Auth.auth().addStateDidChangeListener { auth, user in
//            guard let user = user else { return }
//            self.user = User(authData: user)
//        }
//        do{
//            let retrievedImage = try Disk.retrieve("currentImage.png", from: .caches, as: UIImage.self)
//            self.uiImageView.image = retrievedImage
//            
////            print(retrieved)
//        } catch{
//            print("No old image was found.")
//            setNewPhoto()
//        }
        
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


