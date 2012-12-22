/* Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). Provided "as is" in public domain with no guarantees */
package realtimelib
{
	import realtimelib.session.GroupChat;
	import realtimelib.session.ISession;
	import realtimelib.session.P2PSession;
	import realtimelib.session.UserList;
	import realtimelib.session.UserObject;
	import realtimelib.events.PeerStatusEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import realtimelib.events.GameEvent;

	[Event(name="change",type="flash.events.Event")]
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="userAdded",type="com.adobe.fms.PeerStatusEvent")]
	[Event(name="userRemoved",type="com.adobe.fms.PeerStatusEvent")]
	
	/**
	 * P2PGame class handles movement, position, mouse position, rotation and speed callbacks back to your game
	 * Allows you to distribute realtime data to everyone in the group using RealtimeChannel class
	 */
	public class P2PGame extends EventDispatcher implements IRealtimeGame
	{
		
		private var session:P2PSession;
		public var realtimeChannelManager:RealtimeChannelManager;
		public var receiveObjectCallback:Function;
		
		public var running:Boolean = false;
		
		private var serverAddr:String;
		private var groupName:String;
	
		
		public function P2PGame(serverAddr:String, groupName:String="defaultGroup"){
			this.serverAddr = serverAddr;
			this.groupName = groupName;
		}
				
		/**
		 * creates new session and connects to the group with username and details
		 */
		public function connect(userName:String,userDetails:Object=null):void{
			session = new P2PSession(serverAddr,groupName);			
			session.addEventListener(Event.CONNECT, onConnect);
			session.connect(userName,userDetails);
			trace("CONNECT: "+userName);
		}
		
		/**
		 * closes session
		 */
		public function close():void{
			session.close();
		}
		
		/*
		 * DEFAULT EVENTS
		 */
		protected function onConnect(event:Event):void{
			Logger.log("onConnect");
			session.addEventListener(Event.CHANGE, onUserListChange);
			session.addEventListener(PeerStatusEvent.USER_ADDED, onUserAdded);
			session.addEventListener(PeerStatusEvent.USER_REMOVED, onUserRemoved);
			
			realtimeChannelManager = new RealtimeChannelManager(session);
			
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		protected function onUserListChange(event:Event):void{
			Logger.log("onUserListChange");
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onUserAdded(event:PeerStatusEvent):void{
			if(event.info.id!=session.myUser.id){
				realtimeChannelManager.addRealtimeChannel(event.info.id, this);
				dispatchEvent(event);
			}
		}
		
		protected function onUserRemoved(event:PeerStatusEvent):void{
			if(event.info.id!=session.myUser.id){
				realtimeChannelManager.removeRealtimeChannel(event.info.id);
				dispatchEvent(event);
			}
		}
		
		/**
		 * send object
		 * @param Anything
		 */
		public function sendObject(object:*):void{
			realtimeChannelManager.sendStream.send("receiveObject",session.myUser.id,object);
		}
		
		/**
		 * receive object
		 * @param Anything
		 */
		public function receiveObject(peerID:String,object:*):void{
			if (receiveObjectCallback!=null) receiveObjectCallback(peerID, object);
		}

		
		/**
		 * List of users in the group as an object.
		 */
		public function get userList():Object{
			return session.mainChat.userList;
		}
		
		/**
		 * Returns my user object.
		 */
		public function get myUser():Object{
			return session.myUser;
		}
		
		/**
		 * List of users in the group as an array.
		 */
		public function get userListArray():Array{
			var arr:Array = new Array();
			for(var user:Object in userList){
				arr.push(userList[user].userName);
			}
			return arr;
		}
		
		/**
		 * List of users in the group as a map object.
		 */
		public function get userListMap():Object{
			var obj:Object = new Object();
			for(var id:String in userList){
				obj[id] = userList[id].userName;
			}
			return obj;
		}
		
	}
}