package  nl.bs10.bright.commands.elements {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class FilterElementsCommand extends BrightCommand implements ICommand, IAsyncCommand {
		override public function execute(...args):void {
			super.execute(args);
			switch(args[0][2]) {
				case 'flpublicationdate':
				case 'flmodificationdate':
				case 'flexpirationdate':
				case 'flcreationdate':
					args[0][2] = args[0][2].substr(2);
			}
			
			var call:Object = ServiceController.getService("elementService").filter(args[0][0], 80, args[0][1], args[0][2], args[0][3]);
			call.start = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;	
			var co:Page;
			Model.instance.elementVO.totalElements = result.result.total;
			
			if(result.token.start == 0) {
				if(Model.instance.elementVO.aelements) {
					Model.instance.elementVO.aelements.removeAll();
				}
				Model.instance.elementVO.aelements = new ArrayCollection();
			}
			
			for each(co in result.result.result) {
				Model.instance.elementVO.elements[co.pageId] = co;
				Model.instance.elementVO.aelements.addItem(co);
			}
			var sf:String = (Model.instance.administratorVO.getSetting('element.defaultsort') != null) ?  Model.instance.administratorVO.getSetting('element.defaultsort') :'pageId';
			var ce:Page = new Page();
			if(!ce.hasOwnProperty(sf))
				sf = 'pageId';
			var desc:Boolean = Model.instance.administratorVO.getSetting('element.defaultsortdir') != 'ASC';
			var s:Sort = new Sort();
			s.fields = [new SortField(sf, false, desc, true)];
			Model.instance.elementVO.aelements.sort = s;
			Model.instance.elementVO.aelements.refresh();
			
			SettingsController.setLabels(Model.instance.elementVO.elements, 'element');
			
			Model.instance.applicationVO.isLoading = false;
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			Model.instance.applicationVO.isLoading = false;
			super.faultHandler(event);
		}
	}
}