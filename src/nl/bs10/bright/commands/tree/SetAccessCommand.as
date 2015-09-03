package nl.bs10.bright.commands.tree
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetAccessCommand extends BrightCommand implements IAsyncCommand, ICommand 	{
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("treeService").setTreeAccess(args[0][0], args[0][1]);
			call.treeId = args[0][0];
			call.groups = args[0][1];
			call.callback = args[0][2];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(!result.result) {
				Alert.show("Could not change the access rights of the page, please try again", "Setting access failed");
				return;
			}
			
			var lr:Boolean = result.token.groups.length > 0
			
			Model.instance.structureVO.treeItems[result.token.treeId].loginrequired = lr;
			Model.instance.structureVO.structure.refresh();
			result.token.callback()
			
			Application.application.showActionBar('info', 'Done');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}

	}
}