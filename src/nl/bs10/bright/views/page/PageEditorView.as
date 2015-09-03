package nl.bs10.bright.views.page
{
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.content.ItemEditorView;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.fur.vein.events.VeinDispatcher;

	public class PageEditorView extends ItemEditorView
	{
		public function PageEditorView()
		{
			super();
		}
		
		override public function cancel(currentItem:IPage = null):void {
			super.cancel(currentItem);
			
			if(Model.instance.structureVO.currentItem)
				Model.instance.structureVO.currentItem = null;
			
			VeinDispatcher.instance.dispatch('updatePageListScrollPosition', null);
		}
	}
}