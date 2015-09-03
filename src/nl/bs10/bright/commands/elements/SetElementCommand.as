package nl.bs10.bright.commands.elements {
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetElementCommand extends BrightCommand implements IAsyncCommand, ICommand	{
		override public function execute(...args):void {
			super.execute(args);

			var call:Object = ServiceController.getService("elementService").setElement(args[0][0] as Page);
			if(args[0][1])
				call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var s:Sort = Model.instance.elementVO.aelements.sort;
			
			for each(var element:Page in result.result) {
				Model.instance.elementVO.elements[element.pageId] = element;
			}

			Model.instance.elementVO.elementsChanged = !Model.instance.elementVO.elementsChanged ;
			Model.instance.elementVO.aelements.sort = s;
			Model.instance.elementVO.aelements.refresh();

			if(result.token.callback)
				result.token.callback();
			
			Application.application.showActionBar('success', 'Element saved');
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}