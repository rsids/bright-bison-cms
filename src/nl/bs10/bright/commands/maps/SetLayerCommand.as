package nl.bs10.bright.commands.maps {
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Layer;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetLayerCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("layerService").setLayer(args[0][0]);
			
			call.addIt = (args[0].length > 1 && args[0][1] == true);
			call.callback = args[0][2];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var s:Sort = Model.instance.markerVO.alayers.sort;
			
			for each(var layer:Layer in result.result.layers) {
				if(Model.instance.markerVO.layers[layer.layerId])
					layer.visible = Model.instance.markerVO.layers[layer.layerId].visible;
				Model.instance.markerVO.layers[layer.layerId] = layer;
			}
			if(!(result.result.layer is Boolean)) {
				if(result.token.addIt)
					result.result.layer.visible = true;
				
				// No need for this, we just did that in the for each, and there is a visibility check
				// @todo Check if this has any consequenses
				//Model.instance.markerVO.layers[result.result.layer.layerId] = result.result.layer;
				
				Model.instance.markerVO.layersChanged = !Model.instance.markerVO.layersChanged ;
				Model.instance.markerVO.alayers.sort = s;
				Model.instance.markerVO.alayers.refresh();
				
				if(result.token.callback)
					result.token.callback(Model.instance.markerVO.layers[result.result.layer.layerId]);
				
				Application.application.showActionBar('success', 'Layer saved');
			}
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}