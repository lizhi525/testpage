package realtimelib
{
	import realtimelib.session.ISession;
	import realtimelib.session.UserObject;
	
	import flash.events.IEventDispatcher;

	[Event(name="change",type="flash.events.Event")]
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="userAdded",type="com.adobe.fms.PeerStatusEvent")]
	[Event(name="userRemoved",type="com.adobe.fms.PeerStatusEvent")]
	public interface IRealtimeGame extends IEventDispatcher
	{
		function connect(userName:String,userDetails:Object=null):void;
		function close():void;
		
		function sendObject(object:*):void;
		
		/*function get session():ISession;
		function set session(value:ISession):void;*/
		
		function get myUser():Object;
		function get userList():Object;
		function get userListArray():Array;
		function get userListMap():Object;
	}
}