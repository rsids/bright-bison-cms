package nl.bs10.bright.commands.config {	

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.flexperiments.display.Transformations;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetLogoCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("configService").getLogo();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;

			if(result.result) {
				var ldr:Loader = new Loader();
				ldr.load(new URLRequest(result.result.toString()));
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, _loadComplete, false, 0, true);
				ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void{}, false, 0, true);
				ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, function():void{}, false, 0, true);
			}
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
		private function _loadComplete(event:Event):void {
			var ldr:LoaderInfo = event.currentTarget as LoaderInfo;
			var bmd:BitmapData = new BitmapData(117,117, true, 0x000000);
			/* var m:Matrix = Transformations.getScaleMatrix(ldr.content, 117,117, false);
			m.ty = 117 - (ldr.content.height * m.d);
			 bmd.draw(ldr.content, m, null, null, null, true);
			 */
			 bmd.draw(ldr.content, null, null, null, null, true);
			
			Model.instance.applicationVO.logo = new Bitmap(bmd);
			Model.instance.applicationVO.logo.smoothing = true;
			Model.instance.applicationVO.logo.pixelSnapping = PixelSnapping.NEVER;
			
			bmd = new BitmapData(52,35, true, 0x000000);
			bmd.draw(ldr.content, Transformations.getScaleMatrix(ldr.content, 52,35, false), null, null, null, true);
			Model.instance.applicationVO.logo_bw = new Bitmap(bmd);
			Model.instance.applicationVO.logo_bw.filters = [Transformations.getBwFilter()];
		}
		
	}
}