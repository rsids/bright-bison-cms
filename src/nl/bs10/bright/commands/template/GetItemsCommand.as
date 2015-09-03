package nl.bs10.bright.commands.template
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.flexperiments.debug.ASDebugger;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	/**
	 * @deprecated 
	 * @author Ids
	 * 
	 */
	public class GetItemsCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {  
			super.execute(args);
			
			var call:Object = ServiceController.getService("templateService").getItems(args[0][0].id);
			call.parent = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			for each(var obj:Object in result.result as Array) {
				obj.label = obj.itemId;
			}
			result.token.parent.children = new ArrayCollection(result.result as Array);
			Model.instance.contentVO.items.refresh();
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}