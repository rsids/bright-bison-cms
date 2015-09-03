package nl.bs10.bright.commands.administrators {
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Administrator;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class UpdateAdminCommand extends BrightCommand implements IAsyncCommand, ICommand {

		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("adminService").updateAdministrator(args[0][0] as Administrator);
			
			call.setPermissions = (args[0][0].id == Model.instance.administratorVO.administrator.id);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.administratorVO.administrators = result.result as Array;
			if(result.token.setPermissions) {
				for each(var administrator:Administrator in Model.instance.administratorVO.administrators) {
					if(administrator.id == Model.instance.administratorVO.administrator.id)
						PermissionController.instance.setPermissions(administrator.permissions);
				}
				
				Model.instance.applicationVO.setNavitems();
			}
			Model.instance.administratorVO.editAdministrator = null;
			
			Application.application.showActionBar('success', 'Administrator updated');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}