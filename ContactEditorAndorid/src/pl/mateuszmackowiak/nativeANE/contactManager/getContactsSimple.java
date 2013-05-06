package pl.mateuszmackowiak.nativeANE.contactManager;

import java.util.ArrayList;
import java.util.List;

import android.database.Cursor;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.util.Log;


import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class getContactsSimple implements FREFunction {
	
	public static final String KEY= "getContactsSimple";
	public static final String TAG = "ContactEditor";
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) 
	{
		try {
			Log.d(TAG, "Entering getContactSimple.call()");

			// Variables 
			int countNum = 0;
			int numContacts;
			Integer addrBookContactPropertyId;
			String addrBookContactPropertyCompositeName;
			FREObject contact = null;
			
			// Paging parameters
			int startPageIndex = args[0].getAsInt();
			int pageLength = args[1].getAsInt();
			Log.d(TAG, "Paring params : startPageIndex = " + startPageIndex + ", pageLength = " + pageLength);
			
			// Retrieve cursor to AddressBook provider and move cursor to desired position
			Cursor contactCursor =  context.getActivity().getContentResolver().query(
					Phone.CONTENT_URI, 
					new String[] { Phone.CONTACT_ID, Phone.DISPLAY_NAME },null, null
					,Phone.DISPLAY_NAME + " COLLATE LOCALIZED ASC");
			numContacts = contactCursor.getCount();
			contactCursor.moveToPosition(startPageIndex);
			Log.d(TAG, "Found "+numContacts+" contacts in AddressBook.");
			Log.d(TAG, "Moved cursor to position ["+startPageIndex+"]");

			// Iterate thru the cursor until we have "pageLength" items
			List<FREObject> contactList = new ArrayList<FREObject>();
			if ( numContacts > 0 ) {
				while (countNum < pageLength) {
					try {
						contact = FREObject.newObject("Object", null);
						addrBookContactPropertyCompositeName =contactCursor.getString(1);
						Log.d(TAG, "Retrieving contact["+countNum+"] = "+addrBookContactPropertyCompositeName);
						addrBookContactPropertyId = contactCursor.getInt(0);
						if(addrBookContactPropertyCompositeName!=null) {
						  contact.setProperty(Details.TYPE_COMPOSITENAME, FREObject.newObject(addrBookContactPropertyCompositeName));
						}
						contact.setProperty(Details.TYPE_RECORD_ID, FREObject.newObject(addrBookContactPropertyId));
			 			contactList.add(contact);
					  	countNum++;
					  	contactCursor.moveToNext();
					} catch (Exception e) {
						context.dispatchStatusEventAsync(ContactEditor.ERROR_EVENT,KEY+e.toString());
					}
				}
			}			
			contactCursor.close();
			
			// Prepare data for ActionScript 3
			FREArray contacts = FREArray.newArray(contactList.size());
			for (int i = 0; i < contactList.size(); i++) {
				contacts.setObjectAt(i, contactList.get(i) );
			}
			
			// Return data
			Log.d(TAG, "Exiting getContactSimple.call()");
			return contacts;
		} 
		catch (Exception e) 
		{
			context.dispatchStatusEventAsync(ContactEditor.ERROR_EVENT, KEY + e.toString());
			e.printStackTrace();
			return null;
		}
	}

}
