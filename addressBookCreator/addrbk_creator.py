import csv
from random import choice
"""
INSTRUCTIONS
---------------
You can use the python script to generate an address book and import it to a device to simulate any 
numbers of contacts on a device.  This script will generate a CSV file in the format required by 
Google Contacts.


HOW TO USE THIS FILE
---------------
Use NUMCONTACTS to control the number of contacts on the device.  Run this script from terminal.
It should generate a file named "addrbk.csv" on the same location.




HOW TO IMPORT THIS FILE INTO GOOGLE Contacts
---------------
IMPORTANT:  Due to the number of contacts generated, it would be best if you use a test account.

Enter Google Contacts (contacts.google.com), on the right side of the screen, you will find an import option
where you can upload the csv file.





HOW TO IMPORT THIS FILE INTO ANDROID AND IOS DEVICES
---------------
For Android, switch your device to the account where the CSV file was imported.  The People application on your device
should update with the information from Google.

For iOS you need to create a new CardDAV account pointing to the Google servers.  More information about this can 
be found in this link [https://support.google.com/mail/answer/2753077?hl=en]  

CardDAV is only available for devices on iOS 5.0 and above. 
"""

# Number of contacts to be generated on the device.
NUMCONTACTS = 1000

def getLastName():
	"""
	"""
	lastNames = ['Abbot', 'Baratheon', 'Caley', 'Drake', 'Eagan', 'Fauser', 'Gillian', 
	'Hall', 'Illiac', 'Jolkin', 'Kent', 'Lannister', 'Masters', 'Nabinger', 'Oak', 'Parker'
	'Quest', 'Rabb', 'Stark', 'Targaryen', 'Uwol', 'Wachlin', 'Xavier', 'Yinz', 'Zita']
	return choice(lastNames)


def phoneNumber(prefix,n):
	"""
	"""
	n = str(n)
	if (len(n) == 1):
		return prefix + "000" + n
	elif (len(n) == 2):
		return prefix + "00" + n
	elif (len(n) == 3):
		return prefix + "0" + n
	elif (len(n) == 4):
		return prefix + n
	else:
		return prefix + n

def createAddressBook():
	"""
	"""
	numContacts = NUMCONTACTS/2

	rows = []
	rows.append(("First Name","Last Name","E-mail Address","Home Address", "Mobile Phone"))
	rows.append(("John", getLastName(), "johndoe@gmail.com", "123 Fake St, Pittsburgh, PA", "(650)-805-0000"))
	rows.append(("Jane", getLastName(), "johndoe@gmail.com", "123 Fake St, Pittsburgh, PA", "(650)-805-0001"))
	
	nameM = "John"
	nameF = "Jane"
	emailM = "johndoe"
	emailF = "janedoe"
	
	for x in range( 0, numContacts ):	
		rows.append(( nameM+str(x), getLastName(), emailM+str(x)+"@gmail.com","123 Fake St, Pittsburgh, PA", phoneNumber("(412) 805-",x)))
		rows.append(( nameF+str(x), getLastName(), emailF+str(x)+"@gmail.com","123 Fake St, Pittsburgh, PA", phoneNumber("(412) 806-",x)))
	
	ofile = open('addrbk.csv',"wb")
	writer = csv.writer(ofile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
	for row in rows:
		writer.writerow(row)
	ofile.close()

if __name__ == '__main__':createAddressBook()