package pl.mllr.extensions.contactEditor
{
	import flash.events.Event;
	
	public class ContactEditorEvent extends Event
	{
		public static const CONTACT_SELECTED:String = "contactSelected";
		public static const CONTACT_ADDED:String = "contactAdded";
		public static const CONTACT_NOT_FOUND:String = "contactNotFound";

		public static const SIMPLE_CONTACTS_READY:String = "simpleContactsReady";
		public static const DETAILED_CONTACT_READY:String = "detailedContactReady";

		private var _recordId:int =-1;
		public function ContactEditorEvent(type:String,_id:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_recordId = int(_id);
			super(type, bubbles, cancelable);
		}
		
		/**
		 * the identyfication number of contact
		 */
		public function get recordId():int
		{
			return _recordId;
		}

	}
}