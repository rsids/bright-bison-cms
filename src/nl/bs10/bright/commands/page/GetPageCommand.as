package nl.bs10.bright.commands.page {
	
	import nl.bs10.bright.commands.config.GetSettingsCommand;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;

	public class GetPageCommand extends BaseCommand implements ICommand {
		
		override public function execute(...args):void {
			
			CommandController.addToQueue(new GetSettingsCommand());
			CommandController.addToQueue(new IntGetPageCommand(), args[0]);
			
			super.execute(args);
		
		}
	}
}