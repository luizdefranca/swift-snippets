
import AVFoundation
import UIKit
import WebRTC
import SocketIO

let TAG = "WebRTCVC"
let VIDEO_TRACK_ID = TAG + "VIDEO"
let AUDIO_TRACK_ID = TAG + "AUDIO"
let LOCAL_MEDIA_STREAM_ID = TAG + "STREAM"

class WebRTCVC: UIViewController, RTCPeerConnectionDelegate, RTCDataChannelDelegate, RTCEAGLVideoViewDelegate {
    
    var mediaStream: RTCMediaStream!
    var localAudioTrack: RTCAudioTrack!
    var remoteAudioTrack: RTCAudioTrack!
    var remoteVideoTrack: RTCVideoTrack!
    var renderer: RTCEAGLVideoView!
    var dataChannel: RTCDataChannel!
    var dataChannelRemote: RTCDataChannel!
    
    var roomName: String!
    
    let manager = SocketManager(socketURL: URL(string: "https://.com")!, config: [.log(false), .compress])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.SpringWood
        
        renderer = RTCEAGLVideoView(frame: self.view.frame)
        renderer.delegate = self
        view.addSubview(renderer)
        
        
        self.socket = manager.defaultSocket
        initWebRTC();
        sigConnect(wsUrl: "https://.com");
        
        localAudioTrack = peerConnectionFactory.audioTrack(withTrackId: AUDIO_TRACK_ID)
        mediaStream = peerConnectionFactory.mediaStream(withStreamId: LOCAL_MEDIA_STREAM_ID)
        mediaStream.addAudioTrack(localAudioTrack)
    }
    
    func getRoomName() -> String {
        return (roomName == nil || roomName.isEmpty) ? "_defaultroom": roomName;
    }
    
    // webrtc
    var peerConnectionFactory: RTCPeerConnectionFactory! = nil
    var peerConnection: RTCPeerConnection! = nil
    var mediaConstraints: RTCMediaConstraints! = nil
    
    var socket: SocketIOClient! = nil
    var wsServerUrl: String! = nil
    var peerStarted: Bool = false
    
    func initWebRTC() {
        RTCInitializeSSL()
        peerConnectionFactory = RTCPeerConnectionFactory()
        
        let mandatoryConstraints = ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "false"]
        let optionalConstraints = [ "DtlsSrtpKeyAgreement": "true", "RtpDataChannels" : "true", "internalSctpDataChannels" : "true"]
        
        
        mediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: mandatoryConstraints, optionalConstraints: optionalConstraints)
        
    }
    
    func connect() {
        if (!peerStarted) {
            sendOffer()
            peerStarted = true
        }
    }
    
    func hangUp() {
        sendDisconnect()
        stop()
    }
    
    func stop() {
        if (peerConnection != nil) {
            peerConnection.close()
            peerConnection = nil
            peerStarted = false
        }
    }
    
    func prepareNewConnection() -> RTCPeerConnection {
        var icsServers: [RTCIceServer] = []
        
        icsServers.append(RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"], username:"",credential: ""))
        
        let rtcConfig: RTCConfiguration = RTCConfiguration()
        rtcConfig.tcpCandidatePolicy = RTCTcpCandidatePolicy.disabled
        rtcConfig.bundlePolicy = RTCBundlePolicy.maxBundle
        rtcConfig.rtcpMuxPolicy = RTCRtcpMuxPolicy.require
        rtcConfig.iceServers = icsServers;
        
        peerConnection = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: mediaConstraints, delegate: self)
        peerConnection.add(mediaStream);
        
        let tt = RTCDataChannelConfiguration();
        tt.isOrdered = false;
        
        
        self.dataChannel = peerConnection.dataChannel(forLabel: "testt", configuration: tt)
        
        self.dataChannel.delegate = self
        print("Make datachannel")
        
        return peerConnection;
    }
    
    // RTCPeerConnectionDelegate - begin [ ///////////////////////////////////////////////////////////////////////////////
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        // scale by height
        let w = renderer.bounds.height * size.width / size.height
        let h = renderer.bounds.height
        let x = (w - renderer.bounds.width) / 2
        renderer.frame = CGRect(x: -x, y: 0, width: w, height: h)
    }
    
    
    
    /** Called when the SignalingState changed. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState){
        print("signal state: \(stateChanged.rawValue)")
    }
    
    
    /** Called when media is received on a new stream from remote peer. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream){
        
        if (stream.audioTracks.count > 1) {
            print("Weird-looking stream: " + stream.description)
            return
        }
        
        if (stream.videoTracks.count == 1) {
            remoteVideoTrack = stream.videoTracks[0]
            remoteVideoTrack.isEnabled = true
            remoteVideoTrack.add(renderer)
        }
        
    }
    
    /** Called when a remote peer closes a stream. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream){}
    
    
    /** Called when negotiation is needed, for example ICE has restarted. */
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection){}
    
    
    /** Called any time the IceConnectionState changes. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState){}
    
    
    /** Called any time the IceGatheringState changes. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState){}
    
    
    /** New ice candidate has been found. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate){
        
        
        print("iceCandidate: " + candidate.description)
        let json:[String: AnyObject] = [
            "type" : "candidate" as AnyObject,
            "sdpMLineIndex" : candidate.sdpMLineIndex as AnyObject,
            "sdpMid" : candidate.sdpMid as AnyObject,
            "candidate" : candidate.sdp as AnyObject
        ]
        sigSend(msg: json as NSDictionary)
        
    }
    
    
    /** Called when a group of local Ice candidates have been removed. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]){}
    
    
    /** New data channel has been opened. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel){
        print("Datachannel is open, name: \(dataChannel.label)")
        dataChannel.delegate = self
        self.dataChannelRemote = dataChannel
    }
    
    
    
    // RTCPeerConnectionDelegate - end ]/////////////////////////////////////////////////////////////////////////////////
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer){
        print("iets ontvangen");
    }
    
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel){
        print("channel.state \(dataChannel.readyState.rawValue)");
    }
    
    
    func sendData(message: String) {
        let newData = message.data(using: String.Encoding.utf8)
        let dataBuff = RTCDataBuffer(data: newData!, isBinary: false)
        self.dataChannel.sendData(dataBuff)
    }
    
    func onOffer(sdp:RTCSessionDescription) {
        print("on offer shizzle")
        
        setOffer(sdp: sdp)
        sendAnswer()
        peerStarted = true;
    }
    
    func onAnswer(sdp:RTCSessionDescription) {
        setAnswer(sdp: sdp)
    }
    
    func onCandidate(candidate:RTCIceCandidate) {
        peerConnection.add(candidate)
    }
    
    func sendSDP(sdp:RTCSessionDescription) {
        print("Converting sdp...")
        
        var type = ""
        
        if sdp.type.rawValue == 2 {
            type = "answer"
        }
        
        let json:[String: AnyObject] = [
            "type" : type as AnyObject,
            "sdp"  : sdp.sdp.description as AnyObject
        ]
        
        print(json)
        sigSend(msg: json as NSDictionary);
    }
    
    func sendOffer() {
        peerConnection = prepareNewConnection();
        peerConnection.offer(for: mediaConstraints) { (RTCSessionDescription, Error) in
            
            if(Error == nil){
                print("send offer")
                
                self.peerConnection.setLocalDescription(RTCSessionDescription!, completionHandler: { (Error) in
                    print("Sending: SDP")
                    //print(RTCSessionDescription as Any)
                    //self.sendSDP(sdp: RTCSessionDescription!)
                    
                    let farid:[String: AnyObject] = [
                        "type" : "offer" as AnyObject,
                        "sdp"  : RTCSessionDescription!.sdp.description as AnyObject
                    ]
                    
                    let json:[String: AnyObject] = [
                        "room" : "_defaultroom" as AnyObject,
                        "id"  : farid as AnyObject,
                        "type": "ios" as AnyObject
                    ]
                    
                    print(json)
                    
                    self.socket.emit("callAnswerer", json)
                })
            } else {
                print("sdp creation error: \(Error)")
            }
            
        }
    }
    
    
    func setOffer(sdp:RTCSessionDescription) {
        if (peerConnection != nil) {
            print("peer connection already exists")
        }
        peerConnection = prepareNewConnection();
        peerConnection.setRemoteDescription(sdp) { (Error) in
            print("remote description")
        }
    }
    
    func sendAnswer() {
        print("sending Answer. Creating remote session description...")
        if (peerConnection == nil) {
            print("peerConnection NOT exist!")
            return
        }
        
        peerConnection.answer(for: mediaConstraints) { (RTCSessionDescription, Error) in
            print("ice shizzle")
            
            if(Error == nil){
                self.peerConnection.setLocalDescription(RTCSessionDescription!, completionHandler: { (Error) in
                    print("Sending: SDP")
                    //print(RTCSessionDescription as Any)
                    
                    let farid:[String: AnyObject] = [
                        "type" : "offer" as AnyObject,
                        "sdp"  : RTCSessionDescription!.sdp.description as AnyObject
                    ]
                    
                    let json:[String: AnyObject] = [
                        "room" : "_defaultroom" as AnyObject,
                        "id"  : farid as AnyObject,
                        "type": "ios" as AnyObject
                    ]
                    
                    print(json)
                    
                    //self.sendSDP(sdp: RTCSessionDescription!)
                    self.socket.emit("callToBack", json)
                })
            } else {
                print("sdp creation error: \(String(describing: Error))")
            }
            
        }
    }
    
    func setAnswer(sdp:RTCSessionDescription) {
        if (peerConnection == nil) {
            print("peerConnection NOT exist!")
            return
        }
        
        peerConnection.setRemoteDescription(sdp) { (Error) in
            print("remote description")
        }
    }
    
    func sendDisconnect() {
        let json:[String: AnyObject] = [
            "type" : "user disconnected" as AnyObject
        ]
        sigSend(msg: json as NSDictionary);
    }
    
    // websocket related operations
    func sigConnect(wsUrl:String) {
        wsServerUrl = wsUrl;
        
        print("connecting to " + wsServerUrl)
        
        socket.on(clientEvent: .connect) {data, ack in
            print("WebSocket connection opened to: " + self.wsServerUrl)
            self.sigEnter()
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("WebSocket connection closed.")
        }
        
        socket.on("chat") { (data, emitter) in
            print(data[0])
        }
        
        // Client
        socket.on("callCaller") { (data, emitter) in
            self.sendOffer()
        }
        
        // Server
        socket.on("answerer") { (data, emitter) in
            let object = data[0] as! NSDictionary
            
            if let sdpObject = object["id"] {
                
                let dic = self.convertToDictionary(text: sdpObject as! String)
                
                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: RTCSdpType.offer.rawValue)!, sdp: dic!["sdp"]! as! String)
                
                print(sdp)
                self.onOffer(sdp: sdp);
            }

        }
        
        // Client and server
        socket.on("callback") { (data, emitter) in
            //print(data[0])
        }
        
        socket.on("message") { (data, emitter) in
            if (data.count == 0) {
                return
            }
            
            let json = data[0] as! NSDictionary
            print("WSS->C: " + json.description)
            
            let type = json["type"] as! String
            
            if (type == "offer") {
                print("Received offer, set offer, sending answer....")
                
                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: RTCSdpType.offer.rawValue)!, sdp: json["sdp"] as! String)
                
                self.onOffer(sdp: sdp);
                
            } else if (type == "answer" && self.peerStarted) {
                print("Received answer, setting answer SDP")
                
                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: RTCSdpType.answer.rawValue)!, sdp: json["sdp"] as! String)
                
                self.onAnswer(sdp: sdp);
                
            } else if (type == "user disconnected" && self.peerStarted) {
                print("disconnected")
                
                self.stop();
            } else if (type == "candidate" && self.peerStarted) {
                print("Received ICE candidate...");
                let candidate = RTCIceCandidate(
                    sdp: json["candidate"] as! String,
                    sdpMLineIndex: Int32(json["sdpMLineIndex"] as! Int),
                    sdpMid: json["sdpMid"] as? String)
                self.onCandidate(candidate: candidate);
            } else {
                print("Unexpected websocket message");
            }
        }
        
        socket.connect();
    }
    
    func sigRecoonect() {
        socket.disconnect();
        socket.connect();
    }
    
    // Client and server
    func sigEnter() {
        let roomName = getRoomName();
        print("Joining to room: \(roomName)")
        
        let json: [String: Any] = [
            "room": roomName
        ]
        
        socket.emit("join", json);
    }
    
    func sigSend(msg:NSDictionary) {
        socket.emit("message", msg)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
