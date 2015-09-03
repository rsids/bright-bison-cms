package nl.bs10.bright.commands.users {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.User;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class UploadCSVCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("userService").uploadCSV(args[0][0], args[0][1]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			Model.instance.userVO.usergroups = new ArrayCollection(result.result.groups as Array);
			Model.instance.userVO.usergroups.refresh();
			
			var s:Sort = Model.instance.userVO.ausers.sort;
			
			for each(var co:User in result.result.users) {
				Model.instance.userVO.users[co.userId] = co;
				co.setGroupString();
			}
			Model.instance.userVO.usersChanged = !Model.instance.userVO.usersChanged;
			Model.instance.userVO.ausers.sort = s;
			Model.instance.userVO.ausers.refresh();
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}