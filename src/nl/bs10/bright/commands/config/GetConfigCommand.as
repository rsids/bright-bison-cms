package nl.bs10.bright.commands.config {	

	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetConfigCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			Model.instance.applicationVO.loadingInfo = "Loading configuration";
			
			var call:Object = ServiceController.getService("configService").getCMSConfig();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		/**
		 * Resulthandler of command 
		 * @param event
		 * @todo Fix the way tabs are stored (in 3 vo's, unneccessary overhead)
		 */		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.applicationVO.config = result.result;
			if(Model.instance.applicationVO.config.general.hasOwnProperty("headerbar") 
				&& Model.instance.applicationVO.config.general.headerbar != null 
				&& Model.instance.applicationVO.config.general.headerbar != "") {
				Model.instance.applicationVO.headerItems = new ArrayCollection(JSON.decode(Model.instance.applicationVO.config.general.headerbar));
			}
			Model.instance.applicationVO.setNavitems();
			
			for each(var lang:String in result.result.general.languages) {
				Model.instance.pageVO.tabs.addItem({label:Model.instance.applicationVO.langlabels[lang], value: lang, icon:Model.instance.applicationVO.langimages[lang]});
				Model.instance.polyVO.tabs.addItem({label:Model.instance.applicationVO.langlabels[lang], value: lang, icon:Model.instance.applicationVO.langimages[lang]});
				Model.instance.markerVO.tabs.addItem({label:Model.instance.applicationVO.langlabels[lang], value: lang, icon:Model.instance.applicationVO.langimages[lang]});
				Model.instance.calendarVO.tabs.addItem({label:Model.instance.applicationVO.langlabels[lang], value: lang, icon:Model.instance.applicationVO.langimages[lang]});
			}
			Model.instance.pageVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			Model.instance.calendarVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			Model.instance.polyVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			Model.instance.markerVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			

			// Elements, Users & Mailings are NOT multilanguage...
			Model.instance.elementVO.tabs.addItem({label:"Template", value: "tpl"});
			Model.instance.elementVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			
			Model.instance.userVO.tabs.addItem({label:"Template", value: "tpl"});
			Model.instance.userVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			
			Model.instance.mailingVO.tabs.addItem({label:"Template", value: "tpl"});
			Model.instance.mailingVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}