package nl.bs10.bright.commands.tree {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class CreateShortcutCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {

			super.execute(args);
			var parentId:int = 0;
			if(args[0][0] != null) 
				parentId = args[0][0].treeId;
			
			var call:Object = ServiceController.getService("treeService").setShortcut(args[0][0].item.shortcut, 
																					args[0][0].item.page.pageId,
																					args[0][0].newparent.treeId,
																					args[0][0].newindex);
			call.parent = args[0][0].newparent;
			call.index = args[0][0].newindex;
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var child:Object;
			
			// Error occured;
			if(!result.result) {
				
				result.token.parent.children.removeItemAt(result.token.index);
				Model.instance.structureVO.structure.refresh();
				return super.resultHandler(event);
			}
			
			var children:Array = new Array();
			for each(child in result.result as Array) {
				if(Model.instance.structureVO.treeItems[child.treeId]) {
					
					// Don't override children property of existing nodes
					for(var prop:String in child) {
						if(prop != "children")
							Model.instance.structureVO.treeItems[child.treeId][prop] = child[prop];
					}	
				} else {
					// New node, just add...
					Model.instance.structureVO.treeItems[child.treeId] = child;
				}
				children.push(Model.instance.structureVO.treeItems[child.treeId]);
			}
				
			Model.instance.structureVO.treeItems[result.token.parent.treeId].children = new ArrayCollection(children);
			Model.instance.structureVO.treeItems[result.token.parent.treeId].numChildren = children.length;
			Model.instance.structureVO.structure.refresh();
			VeinDispatcher.instance.dispatch('shortcutCreated', null);
			
			Application.application.showActionBar('success', 'Shortcut created');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			var fault:FaultEvent = event as FaultEvent;

			fault.token.parent.children.removeItemAt(fault.token.index);
			Model.instance.structureVO.structure.refresh();
			
		} 
		
	}
}