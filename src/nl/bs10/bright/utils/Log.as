package nl.bs10.bright.utils
{
	import flash.external.ExternalInterface;
	
	import nl.bs10.bright.model.Model;

	public class Log
	{
		public function Log()
		{
		}
		
		public static function add(value:String):void {
			var log:String = Model.instance.applicationVO.log;
			if(log != "") {
				log += "\n";
			}
			log += value;
			if(ExternalInterface.available) {
				ExternalInterface.call('console.log', value);
			}
			
			Model.instance.applicationVO.log = log;
		}
	}
}