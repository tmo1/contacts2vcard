contacts2vcard
==============
contacts2vcard is a Perl script for converting Android contacts to vCard format. Its motivation was the need to extract contacts from a backup copy (produced by Oandbackup) of the Android contacts database and import them into a current Android installation. It has been designed for and tested on a copy of the contacts database ('contacts2.db') from Android 9 (Pie) (LineageOS); I do not know how well it will work, if at all, on other versions. The code is based on the excellent (unofficial) documentation of the database format here:
 * https://www.dev2qa.com/android-contacts-database-structure/
 * https://www.dev2qa.com/android-contacts-fields-data-table-columns-and-data-mimetype-explain/

Currently, only name, phone number, and email data are extracted. A future version of the script may extract other data as well.

Dependencies
------------
The script depends on the Perl modules DBD::SQLite and vCard (Debian: libdbd-sqlite3-perl and libtext-vcard-perl).

Invocation
----------
The script is invoked as `contacts2vcard [-d database] [-a address_book] [-v vCard version]`, where 'database' is the database file (including path - the default is 'contacts2.db' in the current directory), 'address_book' is the name of a file (including path - the default is 'address_book' in the current directory) to output the vCard address book to, and 'vCard version' is the desired vCard version (the default is 4.0) The error `DBD::SQLite::db selectall_arrayref failed: no such table: data at perl/contacts2vcard.pl line nnn.` indicates that the script has been pointed at an invalid file or (likely) a nonexistent one.

The Contacts app vCard importer on my Android phone (LineageOS 17.1, based on Android 10) refuses to import version 4.0 vCards ("The format isn't supported"), but it accepts version 2.1.

Alternatives
------------
There are a number of other scripts that purport to do what contacts2vcard does; I have not tried them or studied their code, and contacts2vcard is not based on their code:
 * https://thydzik.com/export-android-contacts-contacts2-db-to-vcard-vcf-on-windows/
 * https://github.com/stachre/dump-contacts2db
 * https://gist.github.com/fenrir-naru/9dafa69e51c7ea99e1ccf5a863da728f
 * https://gist.github.com/1d10t/8ef7a55b5d6ab74b8300ea61376bb678

Cf.:
 * https://stackoverflow.com/questions/18955512/converting-db-to-vcf
 * https://askubuntu.com/questions/445997/how-to-convert-androids-contacts2-db-to-vcf
