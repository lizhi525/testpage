package  
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	import realtimelib.events.PeerStatusEvent;
	import realtimelib.Logger;
	import realtimelib.P2PGame;
	import realtimelib.session.P2PSession;
	import realtimelib.session.UserObject;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Server 
	{
		private var whereAreYouTimer:Timer;
		private var game:Main;
		public var p2p:P2PGame;
		private var id2p:Object = { };
		public function Server(game:Main) 
		{
			this.game = game;
			p2p = new P2PGame("rtmfp://p2p.rtmfp.net/fe0704d85bec8171e0f35e7a-4e39644da8a0/");
			p2p.addEventListener(Event.CONNECT, p2p_connect);
			p2p.addEventListener(Event.CHANGE, p2p_change);
			p2p.connect("test" + Math.random());
			
			p2p.receiveObjectCallback = receiveObject;
		}
		
		private function receiveObject(pid:String, obj:Object):void {
			switch(int(obj[0])) {
				case 1:
					//查找玩家，如果有 改变玩家位置，如果没有 用这个位置新建玩家
					var player:Player =(id2p[pid] = id2p[pid] || game.createPlayer(game.player.x, game.player.y));
					player.setFromServerPath(obj[1]);
					p2p.sendObject([2, player.getServerPath()]);
					break;
				case 2:
					//收到反馈了，可以不发送我在哪里了
					whereAreYouTimer.stop();
					whereAreYouTimer.removeEventListener(TimerEvent.TIMER, whereAreYouTimer_timer);
					player =(id2p[pid] = id2p[pid] || game.createPlayer(game.player.x, game.player.y));
					player.setFromServerPath(obj[1]);
					break;
				case 3://有人位置改变设置之
					player =(id2p[pid] = id2p[pid] || game.createPlayer(game.player.x, game.player.y));
					player.setFromServerPath(obj[1]);
					break;
			}
		}
		
		private function p2p_change(e:Event):void 
		{
			for each(var user:UserObject in p2p.userList) {

			}
		}
		
		private function p2p_connect(e:Event):void 
		{
			p2p.addEventListener(PeerStatusEvent.USER_ADDED, p2p_userAdded);
			p2p.addEventListener(PeerStatusEvent.USER_REMOVED, p2p_userRemoved);
			whereAreYouTimer = new Timer(1000);
			whereAreYouTimer.addEventListener(TimerEvent.TIMER, whereAreYouTimer_timer);
			whereAreYouTimer.start();
			whereAreYouTimer_timer(null);
		}
		
		private function whereAreYouTimer_timer(e:TimerEvent):void 
		{
			p2p.sendObject([1,game.player.getServerPath()]);
		}

		private function p2p_userRemoved(e:PeerStatusEvent):void
		{
			game.removePlayer(id2p[e.info.id]);
			id2p[e.info.id] = null;
			delete id2p[e.info.id];
		}

		private function p2p_userAdded(e:PeerStatusEvent):void
		{
			id2p[e.info.id] = game.createPlayer(game.player.x, game.player.y);
		}
		
	}

}