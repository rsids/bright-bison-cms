package nl.bs10.bright.commands.tree {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.Node;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class UpdateTreeCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		
		override public function execute(...args):void {
			super.execute(args);
			var items:Array = Model.instance.structureVO.tree.findNodes("open", true);
			var idarr:Array = new Array();
			for each(var node:Node in items) {
				idarr.push(node.data.treeId);
			}
			if(idarr.length == 0)
				idarr.push(1);
			var call:Object = ServiceController.getService("treeService").getChildrenByIds(idarr);
			call.opened = idarr;
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var child:Object;
			
			var children:Array = new Array();
			Model.instance.structureVO.treeItems = new Array();
			Model.instance.structureVO.structure.removeAll();
			Model.instance.structureVO.structure = new ArrayCollection();
			
			for each(child in result.result.arr) {
				Model.instance.structureVO.treeItems[child.treeId] = child;
			}
			Model.instance.structureVO.structure.addItem(result.result.tree);
			Application.application.callLater(_open, [result.token.opened]);
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			Model.instance.structureVO.structure.refresh();
		} 
		
		private function _open(items:Array):void {
			for each(var id:int in items) {
				var n:Node = Model.instance.structureVO.tree.findNodes("data.treeId", id)[0];
				if(n)
					n.open = true;
			}
		}
		
	}
}