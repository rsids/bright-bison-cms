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


	public class MovePageCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {

			super.execute(args);
			var call:Object = ServiceController.getService("treeService").movePage(	args[0][0].item.data.treeId, 
																					args[0][0].oldparent.treeId,
																					args[0][0].newparent.treeId,
																					args[0][0].oldindex,
																					args[0][0].newindex);
			call.newparent = args[0][0].newparent;
			call.oldparent = args[0][0].oldparent;
			call.oldindex = args[0][0].oldindex;
			call.newindex = args[0][0].newindex;
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var child:TreeNode;
			var xml:XML = describeType(new TreeNode());
			var prop:String;
			var accessor:XML
			
			if(!result.result) {
				// Error occured;
				return super.resultHandler(event);
			}
			var newchildren:Array = new Array();
			var oldchildren:Array = new Array();
			
			for each(child in result.result.newParent as Array) {
				if(Model.instance.structureVO.treeItems[child.treeId]) {
					
					// Don't override children property of existing nodes
					for each(accessor in xml..accessor) {
						prop = accessor.@name;
						if(prop != "children")
							Model.instance.structureVO.treeItems[child.treeId][prop] = child[prop];
					}
				} else {
					// New node, just add...
					Model.instance.structureVO.treeItems[child.treeId] = child;
				}
				
				newchildren.push(Model.instance.structureVO.treeItems[child.treeId]);
			}
			
			for each(child in result.result.oldParent as Array) {
				if(Model.instance.structureVO.treeItems[child.treeId]) {
					
					// Don't override children property of existing nodes
					for each(accessor in xml..accessor) {
						prop = accessor.@name;
						if(prop != "children")
							Model.instance.structureVO.treeItems[child.treeId][prop] = child[prop];
					}
				} else {
					// New node, just add...
					Model.instance.structureVO.treeItems[child.treeId] = child;
				}
				
				oldchildren.push(Model.instance.structureVO.treeItems[child.treeId]);
			}
			Model.instance.structureVO.treeItems[result.token.newparent.treeId].children = new ArrayCollection(newchildren);
			Model.instance.structureVO.treeItems[result.token.oldparent.treeId].children = new ArrayCollection(oldchildren);
			Model.instance.structureVO.structure.refresh();
			
			Application.application.showActionBar('success', 'Page Moved');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			var fault:FaultEvent = event as FaultEvent;
			var child:* = fault.token.newparent.children.removeItemAt(fault.token.newindex);
			if(fault.token.newparent.children.length == 0)
				delete fault.token.newparent.children;
				
			fault.token.oldparent.children.addItemAt(child, fault.token.oldindex);
			Model.instance.structureVO.structure.refresh();
		} 
	}
}