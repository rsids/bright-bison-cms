package nl.bs10.bright.commands.tree
{
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.TreeNode;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class DeletePageFromTreeCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var call:Object
			if(args[0][1] && args[0][1] === true) {
				var arr:Array = new Array();
				for each(var tn:TreeNode in args[0][0]) {
					arr.push(tn.treeId);
				}
				call = ServiceController.getService("treeService").removeChildren(arr);
				call.deleted = args[0][0];
			} else {
				call = ServiceController.getService("treeService").removeChild(args[0][0].treeId);
				call.deleted = [args[0][0]];
				
			}
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(!result.result) {
				// Error occured;
				return super.resultHandler(event);
			}
			for each(var tn:TreeNode in result.token.deleted) {
				
				var parent:TreeNode = Model.instance.structureVO.treeItems[tn.parentId];
				for each(var child:TreeNode in parent.children) {
					if(child.treeId == tn.treeId) {
						Model.instance.pageVO.pages[child.page.pageId].usecount--;
						parent.children.removeItemAt(parent.children.getItemIndex(child));
						parent.numChildren--;
						if(parent.numChildren == 0) {
							delete parent.children;// = null;
						} else {
							parent.children.refresh();
						}
						break;
					}
				}
			}
			Model.instance.pageVO.pagesChanged = !Model.instance.pageVO.pagesChanged;
			
/**
* @TODO: CHECK IF THIS WORKS! 
*/			
			//Model.instance.structureVO.structure.refresh();
			
			Application.application.showActionBar('delete', 'Removed');

			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		} 
		
	}
}