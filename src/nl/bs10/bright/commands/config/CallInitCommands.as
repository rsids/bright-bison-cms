package nl.bs10.bright.commands.config {
	import nl.bs10.bright.commands.administrators.GetAdministratorsCommand;
	import nl.bs10.bright.commands.page.GetPagesCommand;
	import nl.bs10.bright.commands.template.GetPluginsCommand;
	import nl.bs10.bright.commands.template.GetTemplateDefinitionsCommand;
	import nl.bs10.bright.commands.tree.GetChildrenCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;

	public class CallInitCommands extends BaseCommand implements ICommand {

		
		override public function execute(...args):void {
			Model.instance.applicationVO.isLoading = true;
			CommandController.addToQueue(new LoadIconsCommand());
			CommandController.addToQueue(new LoadLangsCommand());
			CommandController.addToQueue(new GetConfigCommand());
			CommandController.addToQueue(new GetPluginsCommand(), 'core');
			CommandController.addToQueue(new GetPluginsCommand(), 'custom');
			CommandController.addToQueue(new GetAdministratorsCommand());
			CommandController.addToQueue(new GetTemplateDefinitionsCommand());
			CommandController.addToQueue(new GetPagesCommand(), 0);
			CommandController.addToQueue(new GetChildrenCommand(), null);
			CommandController.addToQueue(new FinishInitCommand());
			super.execute(args);
		}
		
	}
}