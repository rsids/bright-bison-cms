package nl.bs10.bright.commands.template {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetTemplateDefinitionsCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			Model.instance.applicationVO.loadingInfo = "Loading templates";
			
			var call:Object = ServiceController.getService("templateService").getTemplateDefinitions();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.templateVO.templateDefinitions = new ArrayCollection(result.result as Array);
			for each (var template:Template in Model.instance.templateVO.templateDefinitions) {
				Model.instance.pageVO.filterTemplateIds[template.id] = true;
			}
			IconController.definitions = Model.instance.templateVO.rawTemplateDefinitions;
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}