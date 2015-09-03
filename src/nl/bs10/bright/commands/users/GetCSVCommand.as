package nl.bs10.bright.commands.users {
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.ICommand;

	public class GetCSVCommand extends BaseCommand implements ICommand {
		
		override public function execute(...args):void {	
			navigateToURL(new URLRequest(Model.instance.applicationVO.config.general.siteurl + "bright/library/Bright/http/?action=downloadCSV"));
			super.execute(args);
		}
		
	}
}