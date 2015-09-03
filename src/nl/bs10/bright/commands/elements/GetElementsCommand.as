package  nl.bs10.bright.commands.elements {
	
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetElementsCommand extends BrightCommand implements ICommand, IAsyncCommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("elementService").getElements(Model.instance.elementVO.elementsFetched);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var s:Sort = Model.instance.elementVO.aelements.sort;
			for each(var co:Page in result.result) {
				Model.instance.elementVO.elements[co.pageId] = co;
			}
			Model.instance.elementVO.elementsFetched = true;
			Model.instance.elementVO.elementsChanged = !Model.instance.elementVO.elementsChanged;
			Model.instance.elementVO.aelements.sort = s;
			Model.instance.elementVO.aelements.refresh();
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}