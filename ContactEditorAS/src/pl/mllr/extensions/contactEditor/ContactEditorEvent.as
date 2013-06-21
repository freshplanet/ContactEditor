package pl.mllr.extensions.contactEditor
{
	import flash.events.Event;
	
	public class ContactEditorEvent extends Event
	{
		public static const ADDRESS_BOOK_ACCESS_DENIED : String = "ADDRESS_BOOK_ACCESS_DENIED";
		public static const NUM_CONTACT_UPDATED : String = "NUM_CONTACT_UPDATED";
		public static const SIMPLE_CONTACTS_UPDATED : String = "SIMPLE_CONTACTS_UPDATED";
		public static const DETAILED_CONTACT_UPDATED:String = "DETAILED_CONTACT_UPDATED";
		public static const DETAILED_CONTACTS_UPDATED:String = "DETAILED_CONTACTS_UPDATED";
		
		private var _data:Object = null;
		
		public function ContactEditorEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * the identyfication number of contact
		 */
		public function get data():Object
		{
			return _data;
		}

	}
}