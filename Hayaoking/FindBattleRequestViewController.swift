//
//  FindBattleRequestViewController.swift
//  Hayaoking
//
//  Created by 長安尚之 on 2017/03/29.
//  Copyright © 2017年 長安尚之. All rights reserved.
//


//ここでは，試合の申し込みが受理さvarたか，もしくは自分に試合が申し込まれているかを調べる。

// 対戦記録テーブルの中で,「対戦を申し込まれた人のuserIDが自分」かつ，試合の成立がfalseであるものが存在すれば，それを表示する。試合を受けるなら，試合の成立をtrueにする。試合を受けないなら，行ごとテーブルを削除する。

// 対戦記録テーブルの中で，「対戦を申し込んだ人のuserIDが自分」かつ，試合の成立がtrueであるものが存在すれば，目覚ましボタンの画面に遷移し，アラート(予定)で試合受理を伝える。

import UIKit
import Foundation
import SwiftyJSON
import Alamofire

class FindBattleRequestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    @IBOutlet weak var titleText: UILabel!  // タイトルテキスト
    
    @IBAction func pushStartButton(_ sender: Any) {
        // 初回のボタンクリックでは，ユーザ名を入力させるダイアログを表示する。
        // 二回目以降では，バトルのリクエストがあるかを確認する。
        if UserDefaults.standard.bool(forKey: "signUp") == false {
            // 初回，ユーザ名を入力させ，登録する処理
            let signUpAlert = UIAlertController(title: "初回登録", message: "ユーザ名を入力してください", preferredStyle: .alert)

            // テキストフィールドを追加
            signUpAlert.addTextField(configurationHandler: {(userNametextField: UITextField!) -> Void in
                userNametextField.placeholder = "ユーザ名"
 
                let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                    let userName = userNametextField.text
                    self.registerUserName(inputtedUserName: userName!)
                })
                signUpAlert.addAction(okAction)

                
                })
            
            
            
            // アラートを画面に表示
            self.present(signUpAlert, animated: true, completion: nil)

            
            
            
            
            
            

            

            

            
        }else{
            // 二回目以降，バトルリクエストの有無をしらべる処理,サーバと通信して確かめる。
        }

    }
    
    func registerUserName(inputtedUserName: String) -> Void {
        // 入力されたユーザ名の登録をリクエストとして送る関数。成功したら画面遷移
        let req = ["name":inputtedUserName]
        debugPrint(req)
        Alamofire.request("http://52.196.173.16/users.json", method: .post, parameters:req).responseJSON{ response in
            let userJson = JSON(response.result.value!)  // ユーザ名が被っていると，ここでエラーが出る。あとで対応。
            let userId = userJson["id"].intValue  // 悩んだところ。
            
            let owner = UserDefaults.standard
            owner.set(userJson["id"].intValue, forKey: "userId")
            owner.set(userJson["name"].stringValue, forKey: "userName")
            owner.synchronize()
            debugPrint(owner.string(forKey: "userId"))
            debugPrint(owner.string(forKey: "userName"))
            
            
            //　成功した時のダイアログ表示
            let signUpCompleteAlert = UIAlertController(title: "成功", message: "登録完了しました", preferredStyle: .alert)
            let signUpComplete = UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction!) -> Void in
                
                // 画面遷移
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "OWVC") as! OpponentWaitingViewController
                let owner = User(user_id: userJson["id"].intValue, name: userJson["name"].stringValue)
                debugPrint("hoge")
                debugPrint(owner.name)
                nextView.owner = owner
                self.present(nextView, animated: true, completion: nil)
            })
            signUpCompleteAlert.addAction(signUpComplete)
            self.present(signUpCompleteAlert, animated: true, completion: nil)
        }

        
        
        
    }
    

    
}
