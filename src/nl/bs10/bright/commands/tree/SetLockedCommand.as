package nl.bs10.bright.commands.tree {
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetLockedCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("treeService").setLocked(args[0][0], args[0][1]);
			call.treeId = args[0][0];
			call.locked = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(!result.result) {
				Alert.show("Could not lock the page, please try again", "Lock failed");
				return;
			}
			
			Model.instance.structureVO.treeItems[result.token.treeId].locked = result.token.locked;
			if(result.token.locked) {
				var tid:int = Model.instance.structureVO.treeItems[result.token.treeId].parentId;
				while (tid != 0) {
					Model.instance.structureVO.treeItems[tid].locked = true;
					tid = Model.instance.structureVO.treeItems[tid].parentId;
				}
				Application.application.showActionBar('lock', 'Page locked');
			} else {
				Application.application.showActionBar('lock_open', 'Page unlocked');
				
			}
			Model.instance.structureVO.structure.refresh();
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}