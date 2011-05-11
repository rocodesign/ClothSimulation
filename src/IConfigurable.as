package
{
	import org.aswing.JPanel;
	
	public interface IConfigurable
	{
		// this function will be called as soon as
		// the object is going to be added via 'addConfigurable'
		function createUI( pane: JPanel ): void

		// function toDefaultValues(): void
	}
}