package nl.bs10.bright.commands.administrators {
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class SetSettingsCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			// Fix for weird AMFPHP 2.x bug,
			// Infinite recursive object
			var o:Object = args[0][0];
			if(o.hasOwnProperty('null'))
				delete o['null'];
			if(o.hasOwnProperty('_externalizedData'))
				delete o['_externalizedData'];
			
			var call:Object = ServiceController.getService("adminService").setSettings(o);

			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.administratorVO.administrator.settings = result.result;
			
			var nc:uint = Model.instance.administratorVO.callbacks.length;
			while(--nc > -1) {
				Model.instance.administratorVO.callbacks.pop()();
			}
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}