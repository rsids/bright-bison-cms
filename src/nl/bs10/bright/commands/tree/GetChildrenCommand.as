package nl.bs10.bright.commands.tree
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class GetChildrenCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var parentId:int = 0;
			if(args[0][0] != null) 
				parentId = args[0][0].treeId;
				
			var call:Object = ServiceController.getService("treeService").getChildren(parentId);
			call.parent = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var child:Object;
			
			for each(child in result.result as Array) {
				Model.instance.structureVO.treeItems[child.treeId] = child;
			}
			if(result.token.parent == null) {
				for each(child in result.result as Array) {
					Model.instance.structureVO.structure.addItem(child);
					CommandController.addToQueue(new GetChildrenCommand(), child);
				}
			} else {
				
				Model.instance.structureVO.treeItems[result.token.parent.treeId].children = new ArrayCollection(result.result as Array);
				if(Model.instance.structureVO.treeItems[result.token.parent.treeId].parentId == 0) {
					// rootnode, dispatch event to trigger open event
					VeinDispatcher.instance.dispatch("childrenOfRootNodeFetched", result.token.parent.treeId);
				}
			}
			Model.instance.structureVO.structure.refresh();
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			Model.instance.applicationVO.loadingInfo = "Loading pages FAILED";
			super.faultHandler(event);
		}
		
	}
}