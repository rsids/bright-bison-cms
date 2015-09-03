package nl.bs10.bright.commands.mailing {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.ICommand;
	
	public class ShowPreviewCommand extends BrightCommand implements ICommand {
		
		override public function execute(...args):void {
			var url:String = Model.instance.applicationVO.config.general.siteurl + 'bright/actions/mailing.php?action=preview&id=' + Model.instance.mailingVO.currentItem.pageId;
			navigateToURL(new URLRequest(url), '_blank');
			super.execute(args);
		}
	}
}