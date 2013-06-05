package pl.mateuszmackowiak.nativeANE.contactManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import pl.mateuszmackowiak.nativeANE.contactManager.functions.GetContactCount;
import pl.mateuszmackowiak.nativeANE.contactManager.functions.GetContactDetails;
import pl.mateuszmackowiak.nativeANE.contactManager.functions.GetContactsSimple;
import pl.mateuszmackowiak.nativeANE.contactManager.functions.RetrieveDetailedContact;
import pl.mateuszmackowiak.nativeANE.contactManager.functions.RetrieveSimpleContacts;
import pl.mateuszmackowiak.nativeANE.contactManager.util.AddressBookAccessor;

import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.provider.ContactsContract.CommonDataKinds;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.util.Log;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class ContactEditorContext extends FREContext{
	
	private static final String TAG = "ContactEditor";
	
	public static Intent intent;
	
    @Override
    public void dispose(){
    	if (simpleContacts != null)
    		simpleContacts.clear();
    		simpleContacts = null;
    	
    	if (detailedContacts != null)
    		detailedContacts.clear();
    		detailedContacts = null;
    }
    
    @Override
    public Map<String, FREFunction> getFunctions()
    {
        Map<String, FREFunction> map = new HashMap<String, FREFunction>();
        map.put("getContactCount", new GetContactCount());
        map.put("getContactsSimple", new GetContactsSimple());
        map.put("getContactDetails", new GetContactDetails());
        map.put("retrieveSimpleContacts", new RetrieveSimpleContacts());
        map.put("retrieveDetailedContact", new RetrieveDetailedContact());
        
        return map;
    }

    ///////////////////////////////////////////////////////////////////
    // ADDRESS BOOK EXTENSION API
    ///////////////////////////////////////////////////////////////////
    
    private List<HashMap<String,Object>> simpleContacts = new ArrayList<HashMap<String,Object>>();
    private List<HashMap<String,Object>> detailedContacts = new ArrayList<HashMap<String,Object>>();
    
	public void getContactCount() {
		try{
			Cursor contactCursor =  this.getActivity().managedQuery(Phone.CONTENT_URI, new String[] { Phone.CONTACT_ID, Phone.DISPLAY_NAME },null, null, null);
			int count = contactCursor.getCount();
			dispatchStatusEventAsync("NUM_CONTACT_UPDATED", Integer.toString(count));
			contactCursor.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void getContactsSimple(int batchStart, int batchLength) {
		int index = 0;
		
		// Retrieve cursor to AddressBook provider and move cursor to desired position
		Cursor contactCursor =  this.getActivity().getContentResolver().query(
				Phone.CONTENT_URI, 
				new String[] { Phone.CONTACT_ID, Phone.DISPLAY_NAME },null, null
				,Phone.DISPLAY_NAME + " COLLATE LOCALIZED ASC");
		contactCursor.moveToPosition(batchStart);
		
		// iterate over the cursor, going thru what we want (the batch)
		while (index < batchLength)
		{
			try {
				HashMap<String, Object> contactDict = new HashMap<String, Object>();
				
				// Record ID
				Integer recordId = Integer.valueOf( contactCursor.getInt(0) );
				contactDict.put(AddressBookAccessor.TYPE_RECORD_ID, recordId);
				
				// Composite name
				String compositeName = contactCursor.getString(1);
				if (compositeName != null) {
					contactDict.put(AddressBookAccessor.TYPE_COMPOSITENAME, compositeName);
				}
				
				simpleContacts.add(contactDict);
				contactCursor.moveToNext();
				index++;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		contactCursor.close();
		
		// dispatch event
		String batchId = Integer.toString(batchStart) + "-" + Integer.toString(batchLength);
 		dispatchStatusEventAsync("SIMPLE_CONTACTS_UPDATED", batchId);
	}

	public void getDetailedContact(int recordId) {
		Log.d(TAG, "Entering ContactEditorContext.getDetailedContact() - recordId = " + Integer.toString(recordId));
		
		ContentResolver resolver = this.getActivity().getContentResolver();
		
		HashMap<String, Object> contactDict = new HashMap<String, Object>();
		
		// Retrieve fields from device
		String compositeName = AddressBookAccessor.getContactField(resolver, recordId, CommonDataKinds.Phone.DISPLAY_NAME);
//		String firstName = AddressBookAccessor.getContactField(resolver, recordId, CommonDataKinds.StructuredName.GIVEN_NAME);
//		String lastName =  AddressBookAccessor.getContactField(resolver, recordId, CommonDataKinds.StructuredName.FAMILY_NAME);
		String[] emails = AddressBookAccessor.getEmails(resolver, Integer.toString(recordId) );
		String[] phones = AddressBookAccessor.getPhoneNumbers(resolver, Integer.toString(recordId) );
		
		contactDict.put(AddressBookAccessor.TYPE_RECORD_ID, Integer.valueOf(recordId));
		contactDict.put(AddressBookAccessor.TYPE_COMPOSITENAME, compositeName);
//		contactDict.put(AddressBookAccessor.TYPE_NAME, firstName);
//		contactDict.put(AddressBookAccessor.TYPE_LASTNAME, lastName);
		contactDict.put(AddressBookAccessor.TYPE_EMAILS, emails);
		contactDict.put(AddressBookAccessor.TYPE_PHONES, phones);
		
		detailedContacts.add(contactDict);
		
		dispatchStatusEventAsync("DETAILED_CONTACT_UPDATED", Integer.toString(recordId));
		
		Log.d(TAG, "Exiting ContactEditorContext.getDetailedContact()");
	}

	public FREObject retrieveContactsSimple(int batchStart, int batchLength) {
		Log.d(TAG, "Entering ContactEditorContext.retrieveContactSimple()");
		try {
			FREArray contacts = FREArray.newArray(batchLength);
			
			int indexCurrent = 0;
			for (int i = batchStart; indexCurrent < batchLength; i++) {
				HashMap<String, Object> contactDict = simpleContacts.get(i);
				
				FREObject contact = FREObject.newObject("Object",null);
				
				Integer recordId = (Integer) contactDict.get(AddressBookAccessor.TYPE_RECORD_ID);
				if (recordId != null) {
					contact.setProperty(AddressBookAccessor.TYPE_RECORD_ID, FREObject.newObject(recordId.intValue()));
				}
				
				String compositeName = (String) contactDict.get(AddressBookAccessor.TYPE_COMPOSITENAME);
				if (compositeName != null) {
					contact.setProperty(AddressBookAccessor.TYPE_COMPOSITENAME, FREObject.newObject(compositeName));
				}
				
				contacts.setObjectAt(indexCurrent, contact);
				indexCurrent++;
			}
			
			Log.d(TAG, "Exiting ContactEditorContext.retrieveContactSimple()");
			return contacts;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	public FREObject retrieveDetailedContact() {
		Log.d(TAG, "Entering ContactEditorContext.retrieveDetailedContact()");
		try {
			FREObject contact = FREObject.newObject("Object",null);
			
			HashMap<String, Object> contactDict = detailedContacts.remove(0);
			
			Integer recordId = (Integer) contactDict.get(AddressBookAccessor.TYPE_RECORD_ID);
			if (recordId != null) {
				contact.setProperty(AddressBookAccessor.TYPE_RECORD_ID, FREObject.newObject(recordId.intValue()));
			}
			
			String compositeName = (String) contactDict.get(AddressBookAccessor.TYPE_COMPOSITENAME);
			if (compositeName != null) {
				contact.setProperty(AddressBookAccessor.TYPE_COMPOSITENAME, FREObject.newObject(compositeName));
			}
			
			String name = (String) contactDict.get(AddressBookAccessor.TYPE_NAME);
			if (name != null) {
				contact.setProperty(AddressBookAccessor.TYPE_NAME, FREObject.newObject(name));
			}
			
			String lastName = (String) contactDict.get(AddressBookAccessor.TYPE_LASTNAME);
			if (lastName != null) {
				contact.setProperty(AddressBookAccessor.TYPE_LASTNAME, FREObject.newObject(lastName));
			}
			
			String[] emails = (String[]) contactDict.get(AddressBookAccessor.TYPE_EMAILS);
			if (emails != null) {
				contact.setProperty(AddressBookAccessor.TYPE_EMAILS, toFREArray(emails));
			}
			
			String[] phones = (String[]) contactDict.get(AddressBookAccessor.TYPE_PHONES);
			if (phones != null) {
				contact.setProperty(AddressBookAccessor.TYPE_PHONES, toFREArray(phones));
			}
			
			Log.d(TAG, "Exiting ContactEditorContext.retrieveDetailedContact()");
			return contact;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	private FREObject toFREArray( String[] array ) throws IllegalStateException, FREASErrorException, FREWrongThreadException, FREInvalidObjectException, FRETypeMismatchException
	{
		Log.d(TAG, "Entering ContactEditorContext.toFREArray()");
		FREArray arr = FREArray.newArray(array.length);
		
		for (int i = 0; i < array.length; i++) {
			arr.setObjectAt(i, FREObject.newObject(array[i]));
		}
		
		Log.d(TAG, "Exiting ContactEditorContext.toFREArray()");
		return arr;
	}
    

}
