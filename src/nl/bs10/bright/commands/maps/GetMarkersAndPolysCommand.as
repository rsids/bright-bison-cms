package nl.bs10.bright.commands.maps {
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class GetMarkersAndPolysCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var updatesOnly:Boolean = Model.instance.mapsVO.items != null;
			
			var call:Object = ServiceController.getService("mapsService").getMarkersAndPolys(updatesOnly, null, false);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			for each(var marker:MarkerPage in result.result.gm_markers) {
				Model.instance.markerVO.markers[marker.pageId] = marker;
			}
			for each(var poly:PolyPage in result.result.gm_polys) {
				Model.instance.polyVO.polys[poly.pageId] = poly;
			}
			var arr:Array = [];
			arr = arr.concat(Model.instance.markerVO.markers, Model.instance.polyVO.polys);
			var arr2:Array = [];
			// Need to loop over to remove gaps, since arr is id based
			for each(var item:IPage in arr) {
				if(item)
					arr2.push(item);
			}
			Model.instance.mapsVO.items = new ArrayCollection(arr2);
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}