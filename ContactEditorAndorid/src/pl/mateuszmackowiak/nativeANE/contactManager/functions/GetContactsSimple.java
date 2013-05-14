package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class GetContactsSimple implements FREFunction {

	private static final String TAG = "[ContactEditor] - getContactsSimple";
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		Log.d(TAG, "Entering call");
		
		try {
			int batchStart = args[0].getAsInt();
			int batchLength = args[1].getAsInt();
			((ContactEditorContext) context).getContactsSimple(batchStart, batchLength);
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		Log.d(TAG, "Exiting call");
		return null;
	}

}
