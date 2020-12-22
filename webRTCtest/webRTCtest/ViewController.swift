//
//  ViewController.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/04/11.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import SkyWay
import AVFoundation
import Firebase

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let apiKey: String = "c7e012a3-4e26-4a54-afb0-3915d1e1b1fd"
    let domain: String = "localhost"
    
    var peer: SKWPeer? //Peerオブジェクト
    var remoteStream: SKWMediaStream? //相手のMediaStreamオブジェクト
    var localStream: SKWMediaStream? //自分自身のMediaStreamオブジェクト
    var mediaConnection: SKWMediaConnection?  //MediaConnectionオブジェクト
    var sfuRoom: SKWSFURoom?
    var peerId: String = ""
    var peerIds: [String] = [""] //ListAll時にIDを入れる箱
    var remotePeerId:String = "" //通話相手のPeerIDを入れる
    var roomName: String = "testRoom"
    var aryMediaStreams: NSMutableArray = [] //sfu時の相手のmediaを入れる
    var aryVideoViews: NSMutableDictionary = [:] ///peerIDとmediaを入れる辞書
    
    var handle: AuthStateDidChangeListenerHandle?
    
    
    @IBOutlet weak var myPeerId: UILabel!
    @IBOutlet weak var peerIdList: UILabel!
    @IBOutlet weak var remoteVideo: SKWVideo!
    @IBOutlet weak var localVideo: SKWVideo!
    
    
    //相手の画面用コレクションビュー
    @IBOutlet weak var collection: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryMediaStreams.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // セルのサイズ
        return CGSize(width: 150, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let view: UIView = cell.viewWithTag(1) {
            if let stream: SKWMediaStream = aryMediaStreams.object(at: indexPath.row) as? SKWMediaStream {
                let peerId: String = stream.peerId!
                var video: SKWVideo? = aryVideoViews.object(forKey: peerId) as? SKWVideo
                if video == nil {
                    video = SKWVideo.init(frame: cell.bounds)
                    stream.addVideoRenderer(video!, track: 0)
                    aryVideoViews.setObject(video!, forKey: peerId as NSCopying)
                }
                video!.frame = cell.bounds
                view.addSubview(video!)
                video!.setNeedsLayout()
            }
        }
        return cell
    }
    
    
    @IBAction func makeRoom(_ sender: Any) {
        let option = SKWRoomOption.init()
        option.mode = .ROOM_MODE_SFU
        option.stream = self.localStream
        sfuRoom = peer?.joinRoom(withName: "testRoom", options: option) as? SKWSFURoom
        sfuRoom?.on(.ROOM_EVENT_OPEN) { (obj: NSObject?) in
            self.roomName = obj as! String
        }
        sfuRoom?.on(.ROOM_EVENT_CLOSE) { (obj: NSObject?) in
        }
        sfuRoom?.on(.ROOM_EVENT_STREAM) { (obj: NSObject?) in self.remoteStream = obj as? SKWMediaStream
            self.remoteAudioSpeaker()
            self.aryMediaStreams.add(self.remoteStream!)
            self.collection.reloadData()
        }
    }
    
    
    @IBAction func joinRoom(_ sender: Any) {
        //peerID検索
        SKWPeer.listAllPeers(peer!)() { peerIds in
            let peers = peerIds!.map { $0 as! String }.filter { $0 != self.peerId }
            guard !peers.isEmpty else {
                return
            }
            self.remotePeerId = peers.first!
            self.peerIdList.text = self.remotePeerId
        }
    }
    
    
    @IBAction func callButton(_ sender: Any) {
        //かける時
        mediaConnection = self.peer!.call(withId: remotePeerId, stream: localStream)
        setupMediaConnectionCallbacks(mediaConnection: self.mediaConnection!)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let option: SKWPeerOption = SKWPeerOption.init()
        option.key = apiKey
        option.domain = domain
        option.debug = SKWDebugLevelEnum.DEBUG_LEVEL_ALL_LOGS
        
        peer = SKWPeer(id: nil, options: option)
        
        setupPeerCallbacks(peer: peer!)
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
          // ...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){
        // MARK: MEDIACONNECTION_EVENT_STREAM
        
        mediaConnection.on(.MEDIACONNECTION_EVENT_STREAM) { (obj: NSObject?) in
            self.remoteAudioSpeaker()
            self.remoteStream = obj as? SKWMediaStream
            self.remoteStream?.addVideoRenderer(self.remoteVideo!, track: 0)
            //相手のカメラ・マイク情報を受信したとき
        }
        
        mediaConnection.on(.MEDIACONNECTION_EVENT_CLOSE) { (obj: NSObject?) in
            //切断されたとき
        }
        
        mediaConnection.on(.MEDIACONNECTION_EVENT_ERROR) { (obj: NSObject?) in
            //エラーが発生したとき
        }
        
    }
    
    
    func setupPeerCallbacks(peer: SKWPeer){
        peer.on(.PEER_EVENT_OPEN) { (obj: NSObject?) in
            //初期接続時
            self.peerId = obj as! String
            print(self.peerId)
            self.myPeerId.text = self.peerId
            
            let mediaConstraints = SKWMediaConstraints()
            mediaConstraints.maxWidth = 960
            mediaConstraints.maxHeight = 540
            mediaConstraints.cameraPosition = .CAMERA_POSITION_FRONT
            
            SKWNavigator.initialize(self.peer!)
            self.localStream = SKWNavigator.getUserMedia(mediaConstraints)
            self.localStream?.addVideoRenderer(self.localVideo!, track: 0)
            
        }
        peer.on(.PEER_EVENT_CALL) { (obj: NSObject?) in
            //発信したとき
            self.mediaConnection = obj as? SKWMediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: self.mediaConnection!)
            self.mediaConnection?.answer(self.localStream)
        }
        peer.on(.PEER_EVENT_DISCONNECTED) { (obj: NSObject?) in
            //サーバーと接続が切れたとき
        }
        peer.on(.PEER_EVENT_CLOSE) { (obj: NSObject?) in
            //Peerと接続が切れたとき
        }
        peer.on(.PEER_EVENT_ERROR) { (obj: NSObject?) in
            //エラーが発生したとき
        }
    }
    
    
    func remoteAudioSpeaker() {
        self.remoteStream?.setEnableAudioTrack(0, enable: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
        }
    }
    
}

