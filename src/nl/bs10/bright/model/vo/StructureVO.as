package nl.bs10.bright.model.vo {
	
	import mx.collections.ArrayCollection;
	
	import nl.bs10.brightlib.objects.TreeNode;
	import nl.flexperiments.tree.FlpTree;
	
	[Bindable]
	public class StructureVO {
		
		[Embed(source="/assets/itemicons/lock.png")]
		public var lock_img:Class;
		
		[Embed(source="/assets/itemicons/shortcut.png")]
		public var shortcut_img:Class;
		
		[Embed(source="/assets/itemicons/login.png")]
		public var login_img:Class;
		
		public var structure:ArrayCollection = new ArrayCollection();
		public var treeItems:Array = new Array();
		
		public var selectedNode:TreeNode;
		
		public var tree:FlpTree;
		
		public var currentItem:TreeNode;
		
		/* 
		public function StructureVO() {
			structure.enableAutoUpdate();
		} */
		
	}
}