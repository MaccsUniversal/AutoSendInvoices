Auto Send Invoices

These Codeunits are written to assist users in sending Invoices automatically via the job queue. 
I’ve set it to run every 10 minutes so it picks up recently posted invoices. Once an invoice is sent, it will ignore said invoice each time it runs unless sent using a test email. 
More info below:

Caveats

•	I encountered an issue during testing where the attached pdf could only be opened using a browser pdf reader (Firefox specifically). I’ve since moved some invocations into a separate procedure  ‘SendEmailMsg’. The attached Pdfs now open with readers in commonly used browsers and Adobe Acrobat.
•	This Codeunit runs strictly from the Job Queue. There are no custom pages/tables to display invoices for which emails have been sent/failed to send. You can use the Sent Emails (8889) page and the Emails Outbox (8888) page to view email statuses. 
•	This extension updates the Email Related Records tables, this is where Sales Invoice Headers retrieve data for the Last Email Sent Message Id and Last Email Sent Time. However, I’ve that on the List/Card pages these fields show up blank whereas on the Sales Header Invoice table the correct data is displayed.
•	The Custom Page is strictly for testing and not necessary for deployment so no need to waste an object id with this. 

Email Body

Sure, it would be nice to have a rich text box for editing the email body but this is just an initial release and something I’ll add in later. Not convenient but there is an Integrated Event for developers to modify the body before the email is sent. The email body is Html Formatted so use Html tags where necessary.

Filters

Since there are no pages I’ve used the Parameter String field on the job queue entry to direct the Codeunit on which invoices to send. Filters work in the usual way. Find more information on Filters in BC here. See example below:

Enter a JSON object in the parameter string with the following keys:

{
  "Invoice No.": "",
  "Customer No.": "<>LEM*",
  "Customer Posting Group": "NON NOTIFY|UK*",
  "OffsetDays": 1,
  "Test Email": “email@test.com”
}


Keys    :   Value
Invoice No.	: String	
Custom No.	: String	
Customer Posting Group	: String	

OffsetDays – number of days to go back from current date. Enter 0 for invoice with the current date as the posting date.	: Integer
Test Email – all invoices processed are sent to this address. They are not stored in the Email Related Records table so they can be sent to recipients when testing is complete.	: String



