package nl.bs10.bright.commands.maps
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class GeocodeCommand extends BaseCommand implements IAsyncCommand, ICommand
	{
		public static const FROMLATLNG:uint = 1;
		public static const FROMADDRESS:uint = 2;
		
		override public function execute(...args):void {
			var call:Object = ServiceController.getService("mapsService").geocode(args[0][0], args[0][1]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
			call.marker = args[0][1];
			call.mode = args[0][0]
			super.execute(args);
		}
		
		override public function resultHandler(event:Event):void {
			var result:Object = event['result'];
			var marker:MarkerPage = event['token'].marker;
			if(result.status == "OK" && result.results.length > 0) {
				if(event['token'].mode == FROMLATLNG) {
					var address:Object = result.results[0];
					for each(var component:Object in address.address_components) {
						switch(component.types[0]) {
							case 'street_number':
								marker.number = component.long_name;
								break;
							case 'postal_code_prefix':
							case 'postal_code':
								marker.zip = component.long_name;
								break;
							case 'route':
								marker.street = component.long_name;
								break;
							case 'locality':
								marker.city = component.long_name;
								break;
							case 'country':
								marker.country = component.long_name;
								break;
						}
					}
				} else {
					marker.lat = result.results[0].geometry.location.lat;
					marker.lng = result.results[0].geometry.location.lng;
				}
			} else {
				Alert.show("The address could not be found", "Not found");
			}
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}