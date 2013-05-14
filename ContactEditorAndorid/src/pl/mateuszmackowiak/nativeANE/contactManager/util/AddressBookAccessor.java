package pl.mateuszmackowiak.nativeANE.contactManager.util;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentResolver;
import android.database.Cursor;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Phone;

public class AddressBookAccessor {

	public final static String TYPE_RECORD_ID ="recordId";
	public final static String TYPE_NAME ="name";
	public final static String TYPE_LASTNAME ="lastname";
	public final static String TYPE_COMPOSITENAME ="compositename";
	public final static String TYPE_EMAILS ="emails";
	public final static String TYPE_PHONES ="phones";
	
	public static String[] getPhoneNumbers( ContentResolver resolver, int id )
	{
		Cursor pCur = resolver.query( Phone.CONTENT_URI, 
 				new String[] {Phone.NUMBER},Phone.CONTACT_ID +" = ?",new String[]{Integer.toString(id)}, null);
		
		List<String> phones = new ArrayList<String>();
		
		while (pCur.moveToNext()) {
			phones.add(pCur.getString(pCur.getColumnIndex(Phone.NUMBER)));
		}
		pCur.close();
		
		return (String[]) phones.toArray();
	}
	
	public static String[] getEmails( ContentResolver resolver, int id )
	{
		Cursor eCur = resolver.query( 
 				Email.CONTENT_URI, 
 				new String[] { Email.DATA},Email.CONTACT_ID + " = ?", 
 				new String[]{Integer.toString(id)}, null);
		
		List<String> emails = new ArrayList<String>();
		
		while (eCur.moveToNext()) {
			emails.add(eCur.getString(eCur.getColumnIndex(Email.DATA)));
		}
		eCur.close();
		
		return (String[]) emails.toArray();
	}

	public static String getContactField(ContentResolver resolver, int recordId, String fieldName) 
	{
		String nameS;
		
		Cursor pCur = resolver.query( 
 				Phone.CONTENT_URI, 
 				new String[]{fieldName},
 				Phone.CONTACT_ID + " = ?", 
 				new String[]{Integer.toString(recordId)}, null); 

 		if (pCur.moveToFirst()) { 
 			nameS = pCur.getString(0);
 		} else {
 			nameS = null;
 		}
 		pCur.close();

		return nameS;
	}
}
