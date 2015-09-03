package nl.bs10.bright.commands.users {
	
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.User;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetUserCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("userService").setUser(args[0][0]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			var s:Sort = Model.instance.userVO.ausers.sort;
			for each(var user:User in result.result) {
				Model.instance.userVO.users[user.userId] = user ;
			}

			Model.instance.userVO.usersChanged = !Model.instance.userVO.usersChanged;
			Model.instance.userVO.ausers.sort = s;
			Model.instance.userVO.ausers.refresh();
			
			if(result.token.callback)
				result.token.callback();
				
			Model.instance.userVO.currentItem = null;
			
			Application.application.showActionBar('success', 'User saved');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}