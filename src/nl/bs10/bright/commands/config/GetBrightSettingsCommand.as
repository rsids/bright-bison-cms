package nl.bs10.bright.commands.config
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.settings.SettingsView;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.controllers.ViewController;
	
	public class GetBrightSettingsCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("settingsService").getBrightSettings();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			Model.instance.settingsVO.visibleColumns = new ArrayCollection(result.result.visibleColumns as Array);
			if(ViewController.instance.isRegistered("settingsView"))
				SettingsView(ViewController.instance.getView("settingsView")).refresh();
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}