package nl.bs10.bright.commands.config {
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.ICommand;

	/**
	 * Called when initializing is done and all data is loaded. Loader will be removed and main app shows 
	 * @author bs10
	 * 
	 */
	public class FinishInitCommand extends BaseCommand implements ICommand {
		
		override public function execute(...args):void {
			Model.instance.applicationVO.isLoading = false;
			Model.instance.applicationVO.applicationState = 1;
			super.execute(args);
		}
		
	}
}