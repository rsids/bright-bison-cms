package nl.bs10.bright.commands.users
{
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.User;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class DeleteUserGroupCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("usergroupService").deleteUserGroup(args[0][0]);
			call.groupId = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			if(result.result == true) {
				for each(var group:Object in Model.instance.userVO.usergroups) {
					if(Number(group.groupId) == Number(result.token.groupId)) {
						Model.instance.userVO.usergroups.removeItemAt(Model.instance.userVO.usergroups.getItemIndex(group));
					}
				}
				
				for each(var user:User in Model.instance.userVO.ausers) {
					if(ArrayUtil.arrayContainsValue(user.usergroups, result.token.groupId)) {
						// By setting the whole array, binding should be triggered
						var arr:Array = user.usergroups;
						ArrayUtil.removeValueFromArray(arr, result.token.groupId);
						user.usergroups = arr;
					}
				}
				Model.instance.userVO.usergroups.refresh();
				Application.application.showActionBar('delete', 'Usergroup deleted');
			} else {
				Application.application.showActionBar('error', 'Usergroup could not be deleted, try again');
				
			}
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}