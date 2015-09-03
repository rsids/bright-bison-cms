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

	public class MovePagesCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {

			super.execute(args);
			 var call:Object = ServiceController.getService("treeService").movePages(args[0][0], args[0][1].treeId, args[0][2]);
			call.items = args[0][0];
			call.newparent = args[0][1];
			call.newindex = args[0][2]
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
			
			for (var op:String in result.result.oldParents) {
				var opid:int = parseInt(op);
				var oldchildren:Array = new Array();
				for each(child in result.result.oldParents[opid] as Array) {
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
				Model.instance.structureVO.treeItems[opid].children = new ArrayCollection(oldchildren);
			}
			
			Model.instance.structureVO.treeItems[result.token.newparent.treeId].children = new ArrayCollection(newchildren);
			Model.instance.structureVO.structure.refresh();
			
			Application.application.showActionBar('success', 'Pages Moved');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			var fault:FaultEvent = event as FaultEvent;
			var nac:ArrayCollection = fault.token.newparent.children;
			for (var i:int = 0; i < fault.token.items.length; i++) {
				for (var j:int = 0; j < nac.length; j++) {
					if(nac[j].treeId == fault.token.items[i].treeId) {
						var child:* = nac.removeItemAt(j);
						Model.instance.structureVO.treeItems[fault.token.items[i].oldparentId].children.addItemAt(child, fault.token.items[i].oldindex);
					}
				}
			if(nac.length == 0)
				delete fault.token.newparent.children;
				
			}
			Model.instance.structureVO.structure.refresh();
		} 
	}
}