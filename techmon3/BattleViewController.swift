//
//  BattleViewController.swift
//  techmon3
//
//  Created by RS on 2020/05/14.
//  Copyright © 2020 osuke. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var playerHP = 100
    var playerMP = 0
    var enemyHP = 400
    var enemyMP = 0
    
    var player: Character!
    var enemy: Character!
    var gameTimer: Timer!
    var isPlayerAttackAvilable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        playerHPLabel.text = "\(player.currentHP) / 100"
        playerMPLabel.text = "\(player.currentMP) / 20"
        playerTPLabel.text = "\(player.currentTP) / 100"
        
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        enemyHPLabel.text = "\(enemy.currentHP) / 400"
        enemyMPLabel.text = "\(enemy.currentMP) / 35"
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,            selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()
        print("00000000000000000000000000000")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    func updateUI () {
        
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    func judgeBattle() {
        
        if player.currentHP <= 0 {
            
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
     @objc func updateGame(){
           player.currentMP += 1
           if player.currentMP >= player.maxMP{
               isPlayerAttackAvilable = true
               player.currentMP = player.maxMP //MPはmaxMP以上にならないようにしなきゃだから、currentMPがmaxMPを超えてもmaxMPをキーぷ
           }else{
               isPlayerAttackAvilable = false
           }
           
           enemy.currentMP += 1
           if enemy.currentMP >= enemy.maxMP{
               enemyAttack()
               enemy.currentMP = 0 //敵は自動で攻撃するから、攻撃のたびにcurrentMPを０に
           }

           updateUI()
       }
    
    func enemyAttack() {
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        playerHPLabel.text = "\(player.currentHP) / 100"
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
            updateUI()
           
        }
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool ) {
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvilable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        } else {
            
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        let alert = UIAlertController(title: "バトル終了", message: finishMessage,
                                      preferredStyle : .alert         )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func attackAction() {
        
        if isPlayerAttackAvilable {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
        
            enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
            updateUI()
        judgeBattle()
        }
    }
    
    
    @IBAction func tameruAction() {
        
        if isPlayerAttackAvilable {
            
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
            updateUI()
        }
    }
    
    @IBAction func fireAction() {
        
        if isPlayerAttackAvilable && player.currentTP >= 40 {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            player.currentMP = 0
            updateUI()
            judgeBattle()
        }
    }

}

