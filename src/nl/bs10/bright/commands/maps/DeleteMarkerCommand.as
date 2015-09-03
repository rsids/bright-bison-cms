package nl.bs10.bright.commands.maps
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class DeleteMarkerCommand extends BrightCommand implements IAsyncCommand, ICommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("mapsService").deleteMarker(args[0][0]);
			call.pageId = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			
			var result:ResultEvent = event as ResultEvent;
			if(result.result == true) {
				var ii:int = Model.instance.markerVO.amarkers.getItemIndex(Model.instance.markerVO.markers[result.token.pageId]);
				if(ii > -1) {
					Model.instance.markerVO.amarkers.removeItemAt(ii);
					Model.instance.markerVO.amarkers.refresh();
				}
				ii = Model.instance.mapsVO.items.getItemIndex(Model.instance.markerVO.markers[result.token.pageId]);
				if(ii > -1) {
					Model.instance.mapsVO.items.removeItemAt(ii);
					Model.instance.mapsVO.items.refresh();
				}
				delete Model.instance.markerVO.markers[result.token.pageId];
			}
			super.resultHandler(event);
		}
	}
}