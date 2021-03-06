package nl.bs10.bright.commands.maps {
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetPolyCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("mapsService").setFullPoly(args[0][0] as PolyPage);
			if(args[0][1])
				call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(result.token.callback)
				result.token.callback(result.result);
			
			Application.application.showActionBar('success', 'Poly saved');

			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}