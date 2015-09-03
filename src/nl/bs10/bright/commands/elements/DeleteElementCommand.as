package nl.bs10.bright.commands.elements {
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class DeleteElementCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var pids:Array = new Array();
			for each(var page:Page in args[0][0]) {
				pids.push(page.pageId);
			}
			
			var call:Object = ServiceController.getService("elementService").deleteElements(pids);
			call.pids = pids;
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			if(result.result == true) {
				for each(var pid:int in result.token.pids) {
					var index:int = Model.instance.elementVO.aelements.getItemIndex(Model.instance.elementVO.elements[pid]);
					/* if(index > -1) */
						Model.instance.elementVO.aelements.removeItemAt(index);
						
					delete Model.instance.elementVO.elements[pid];
				}
			}
			/* Model.instance.elementVO.elementsChanged = true;
			Model.instance.elementVO.aelements.refresh(); */
			Application.application.showActionBar('delete', 'Element deleted');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}