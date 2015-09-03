package nl.bs10.bright.commands.maps {
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class DeleteLayerCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("layerService").deleteLayer(Number(args[0][0]));
			call.id = args[0][0];
			call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			if(result.result == true) {
				var index:int = Model.instance.markerVO.alayers.getItemIndex(Model.instance.markerVO.layers[result.token.id]);
				if(index > -1)
					Model.instance.markerVO.alayers.removeItemAt(index);
				delete Model.instance.markerVO.layers[result.token.id];
				Model.instance.markerVO.alayers.refresh();
			}
			result.token.callback(result.token.id);
			
			
			Application.application.showActionBar('delete', 'Layer deleted');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}