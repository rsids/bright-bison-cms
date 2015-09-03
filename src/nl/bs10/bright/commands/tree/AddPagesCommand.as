package nl.bs10.bright.commands.tree
{
	import flash.events.Event;
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.TreeNode;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class AddPagesCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {

			super.execute(args);
			
			var parentId:int = args[0][1].treeId;
			var pages:Array = [];
			for each(var tn:TreeNode in args[0][0]) {
				pages.push(tn.page);
			}
			
			var call:Object = ServiceController.getService("treeService").setPages(	pages, 
																					args[0][1].treeId,
																					args[0][2]);
			call.items = args[0][0];
			call.parent = args[0][1];
			call.index = args[0][2];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var child:TreeNode;
			var xml:XML = describeType(new TreeNode());
			
			// Error occured;
			if(!result.result)
				return super.resultHandler(event);
			
			var children:Array = new Array();
			for each(child in result.result as Array) {
				if(Model.instance.structureVO.treeItems[child.treeId]) {
					
					// Don't override children property of existing nodes
					for each(var accessor:XML in xml..accessor) {
						var prop:String = accessor.@name;
						Model.instance.structureVO.treeItems[child.treeId][prop] = child[prop];
					}
	
				} else {
					// New node, just add...
					Model.instance.structureVO.treeItems[child.treeId] = child;
				}
				children.push(Model.instance.structureVO.treeItems[child.treeId]);
				Model.instance.pageVO.pages[child.page.pageId].usecount = child.page.usecount;
			}
				
			Model.instance.structureVO.treeItems[result.token.parent.treeId].children = new ArrayCollection(children);
			Model.instance.structureVO.treeItems[result.token.parent.treeId].numChildren = children.length;

			Model.instance.structureVO.structure.refresh();
			Model.instance.pageVO.pagesChanged = !Model.instance.pageVO.pagesChanged;
				
			VeinDispatcher.instance.dispatch('updatePageListScrollPosition', null);
			Application.application.showActionBar('success', 'Pages added');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			var fault:FaultEvent = event as FaultEvent;
			
			
			/* var c:int = 0;
			while(c < fault.token.items.length) {
				if(fault.token.parent.children.length > fault.token.index) 
					fault.token.parent.children.removeItemAt(fault.token.index);
					
				c++;
			}
			Model.instance.structureVO.structure.refresh(); */
		} 
	}
}