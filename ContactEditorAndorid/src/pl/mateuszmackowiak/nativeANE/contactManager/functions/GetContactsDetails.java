package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;
import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class GetContactsDetails implements FREFunction {

	private static final String TAG = "ContactEditor";
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		Log.d(TAG, "Entering GetContactsDetails.call()");
		
		int[] records;
		try {
			records = new int[0];
			FREArray freArray = (FREArray) args[0] ;
			long length = freArray.getLength() ;
			for( int i = 0 ; i < length ; ++i )
				records[i] = freArray.getObjectAt(i).getAsInt() ;
			
			((ContactEditorContext) context).getDetailedContacts(records) ;
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		Log.d(TAG, "Exiting GetContactsDetails.call()");
		
		return null;
	}

}
