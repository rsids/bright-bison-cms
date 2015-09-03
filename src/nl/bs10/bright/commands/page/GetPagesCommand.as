package nl.bs10.bright.commands.page {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.vo.TemplateVO;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetPagesCommand extends BrightCommand implements ICommand, IAsyncCommand {
		override public function execute(...args):void {
			super.execute(args);
			Model.instance.applicationVO.loadingInfo = "Loading pages";
			var fields:Array;
			if(Model.instance.applicationVO.config.general.hasOwnProperty("overviewfields"))
				fields = Model.instance.applicationVO.config.general.overviewfields;
				
			var call:Object = ServiceController.getService("pageService").getPages(args[0][0], fields);
			call.pagetype = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var co:Page;
			var s:Sort;
			switch(result.token.pagetype) {
				case TemplateVO.PAGETEMPLATE:
					Model.instance.pageVO.pages = new Array();
					for each(co in result.result) {
						Model.instance.pageVO.pages[co.pageId] = co;
						
					}
					SettingsController.setLabels(Model.instance.pageVO.pages, 'page');
					
					Model.instance.pageVO.pagesChanged = !Model.instance.pageVO.pagesChanged;
					s = new Sort();
					s.fields = [new SortField("modificationdate", false , true)];
					Model.instance.pageVO.apages.sort = s;
					Model.instance.pageVO.apages.refresh();
					break;
				
				case TemplateVO.MAILINGTEMPLATE:
					for each(co in result.result) {
						Model.instance.mailingVO.mailings[co.pageId] = co;
					
					}
					SettingsController.setLabels(Model.instance.mailingVO.mailings, 'mailing');
					Model.instance.mailingVO.updateMailings();
					break;
				
				case TemplateVO.ELEMENTTEMPLATE:
					Model.instance.elementVO.aelements= new ArrayCollection(result.result as Array);	
					Model.instance.elementVO.aelements.refresh();
					break;
				
			
			}
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			Model.instance.applicationVO.loadingInfo = "Loading pages FAILED";
			super.faultHandler(event);
		}
	}
}