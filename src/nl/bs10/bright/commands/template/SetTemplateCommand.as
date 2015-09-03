package nl.bs10.bright.commands.template {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	/**
	 * @author Ids
	 * 
	 */
	public class SetTemplateCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("templateService").setTemplate(args[0][0] as Template, args[0][1]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.templateVO.templateDefinitions = new ArrayCollection(result.result as Array);
			for each (var template:Template in Model.instance.templateVO.templateDefinitions) {
				if(!Model.instance.pageVO.filterTemplateIds[template.id])
					Model.instance.pageVO.filterTemplateIds[template.id] = true;
			}
			IconController.definitions = Model.instance.templateVO.templateDefinitions;
			Model.instance.pageVO.apages.refresh();
			Model.instance.templateVO.templateDefinitions.refresh();
			
			Model.instance.templateVO.selectedTemplate = null;
			
			Application.application.showActionBar('success', 'Template saved');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}