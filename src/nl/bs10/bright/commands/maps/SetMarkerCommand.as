package nl.bs10.bright.commands.maps {
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;

	public class SetMarkerCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("mapsService").setFullMarker(args[0][0] as MarkerPage);
			if(args[0][1]) {
				call.callback = args[0][1];
			}
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(result.token.callback) {
				result.token.callback(result.result);
			}
			
			CommandController.addToQueue(new GetMarkersAndPolysCommand());
			Application.application.showActionBar('success', 'Marker saved');

			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}