package nl.bs10.bright.commands.maps {
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Layer;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetLayersCommand extends BrightCommand implements IAsyncCommand, ICommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("layerService").getLayers(Model.instance.markerVO.layersFetched);
			call.callback = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			var s:Sort = Model.instance.markerVO.alayers.sort;
			for each(var co:Layer in result.result) {
				Model.instance.markerVO.layers[co.layerId] = co;
			}
			Model.instance.markerVO.layersFetched = true;
			Model.instance.markerVO.layersChanged = !Model.instance.markerVO.layersChanged;
			Model.instance.markerVO.alayers.sort = s;
			Model.instance.markerVO.alayers.refresh();
			
			
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}