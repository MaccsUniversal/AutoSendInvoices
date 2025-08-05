<body lang="EN-GB" link="#0563C1" vlink="#954F72" style="tab-interval:36.0pt;
word-wrap:break-word">

<div class="WordSection1">

<p class="MsoNormal"><b><span style="font-size:14.0pt;line-height:107%">Auto Send
Invoices<o:p></o:p></span></b></p>

<p class="MsoNormal">These <span class="SpellE">Codeunits</span> are written to
assist users in sending Invoices automatically via the job queue. I’ve set it
to run every 10 minutes so it picks up recently posted invoices. Once an
invoice is sent, it will ignore said invoice each time it runs unless sent
using a test email. </p>

<p class="MsoNormal">More info below:</p>

<p class="MsoNormal"><b><span style="font-size:14.0pt;line-height:107%">Caveats<o:p></o:p></span></b></p>

<p class="MsoListParagraphCxSpFirst" style="text-indent:-18.0pt;mso-list:l0 level1 lfo2"><!--[if !supportLists]--><span style="font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol"><span style="mso-list:Ignore">·<span style="font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><!--[endif]-->I encountered an issue during testing where the attached
pdf could only be opened using a browser pdf reader (Firefox specifically). I’ve
since moved some invocations into a separate procedure <span style="mso-spacerun:yes">&nbsp;</span>‘<span class="SpellE">SendEmailMsg</span>’. The
attached Pdfs now open with readers in commonly used browsers and Adobe
Acrobat.</p>

<p class="MsoListParagraphCxSpMiddle" style="text-indent:-18.0pt;mso-list:l0 level1 lfo2"><!--[if !supportLists]--><span style="font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol"><span style="mso-list:Ignore">·<span style="font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><!--[endif]-->This <span class="SpellE">Codeunit</span> runs
strictly from the Job Queue. There are no custom pages/tables to display
invoices for which emails have been sent/failed to send. You can use the Sent
Emails (8889) page and the Emails Outbox (8888) page to view email statuses. </p>

<p class="MsoListParagraphCxSpMiddle" style="text-indent:-18.0pt;mso-list:l0 level1 lfo2"><!--[if !supportLists]--><span style="font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol"><span style="mso-list:Ignore">·<span style="font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><!--[endif]-->This extension updates the Email Related Records
tables, this is where Sales Invoice Headers retrieve data for the Last Email
Sent Message Id and Last Email Sent Time. However, I’ve that on the List/Card
pages these fields show up blank whereas on the Sales Header Invoice table the
correct data is displayed.</p>

<p class="MsoListParagraphCxSpLast" style="text-indent:-18.0pt;mso-list:l0 level1 lfo2"><!--[if !supportLists]--><span style="font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol"><span style="mso-list:Ignore">·<span style="font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><!--[endif]-->The Custom Page is strictly for testing and not
necessary for deployment so no need to waste an object id with this. </p>

<p class="MsoNormal"><b><span style="font-size:14.0pt;line-height:107%">Email
Body<o:p></o:p></span></b></p>

<p class="MsoNormal">Sure, it would be nice to have a rich text box for editing the
email body but this is just an initial release and something I’ll add in later.
Not convenient but there is an Integrated Event for developers to modify the
body before the email is sent. The email body is Html Formatted so use Html
tags where necessary.</p>

<p class="MsoNormal"><b><span style="font-size:14.0pt;line-height:107%">Filters<o:p></o:p></span></b></p>

<p class="MsoNormal">Since there are no pages I’ve used the <i>Parameter String</i>
field on the job queue entry to direct the <span class="SpellE">Codeunit</span>
on which invoices to send. Filters work in the usual way. Find more information
on Filters in BC <a href="https://learn.microsoft.com/en-us/dynamics365/business-central/ui-enter-criteria-filters#set-filters-in-reports-batch-jobs-and-xmlports">here</a>.
See example below:</p>

<p class="MsoNormal">Enter a JSON object in the parameter string with the
following keys:</p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto"><i>{<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto;
text-indent:36.0pt"><i>"Invoice No.": "",<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto;
text-indent:36.0pt"><i>"Customer No.": "&lt;&gt;LEM*",<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto;
text-indent:36.0pt"><i>"Customer Posting Group": "NON
NOTIFY|UK*",<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto;
text-indent:36.0pt"><i>"<span class="SpellE">OffsetDays</span>": 1,<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto;
text-indent:36.0pt"><i>"Test Email": “<span class="MsoHyperlink">email@test.com</span>”<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto"><i>}<o:p></o:p></i></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto"><o:p>&nbsp;</o:p></p>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto"><o:p>&nbsp;</o:p></p>

<table class="MsoTableGrid" border="1" cellspacing="0" cellpadding="0" style="border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:1184;mso-padding-alt:0cm 5.4pt 0cm 5.4pt">
 <tbody><tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes">
  <td width="207" valign="top" style="width:155.15pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Key</p>
  </td>
  <td width="191" valign="top" style="width:143.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Type</p>
  </td>
  <td width="203" valign="top" style="width:152.5pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Value Examples</p>
  </td>
 </tr>
 <tr style="mso-yfti-irow:1">
  <td width="207" valign="top" style="width:155.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Invoice No.</p>
  </td>
  <td width="191" valign="top" style="width:143.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">String</p>
  </td>
  <td width="203" valign="top" style="width:152.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">&lt;&gt;PSI000001, PSI000001|PSI000221</p>
  </td>
 </tr>
 <tr style="mso-yfti-irow:2">
  <td width="207" valign="top" style="width:155.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Custom No.</p>
  </td>
  <td width="191" valign="top" style="width:143.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">String</p>
  </td>
  <td width="203" valign="top" style="width:152.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">RFH002..RFH003, &lt;&gt;DSD*</p>
  </td>
 </tr>
 <tr style="mso-yfti-irow:3">
  <td width="207" valign="top" style="width:155.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Customer Posting Group</p>
  </td>
  <td width="191" valign="top" style="width:143.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">String</p>
  </td>
  <td width="203" valign="top" style="width:152.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">UK-END&amp;UK-DIST</p>
  </td>
 </tr>
 <tr style="mso-yfti-irow:4">
  <td width="207" valign="top" style="width:155.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal"><span class="SpellE">OffsetDays</span> – number of days to
  go back from current date. Enter <i>0 </i>for invoice with the current date
  as the posting date.</p>
  </td>
  <td width="191" valign="top" style="width:143.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Integer</p>
  </td>
  <td width="203" valign="top" style="width:152.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">1</p>
  </td>
 </tr>
 <tr style="mso-yfti-irow:5;mso-yfti-lastrow:yes">
  <td width="207" valign="top" style="width:155.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">Test Email – all invoices processed are sent to this
  address. They are not stored in the Email Related Records table so they can
  be sent to recipients when testing is complete.</p>
  </td>
  <td width="191" valign="top" style="width:143.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">String</p>
  </td>
  <td width="203" valign="top" style="width:152.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt">
  <p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:
  0cm;mso-margin-bottom-alt:12.75pt;mso-margin-top-alt:0cm;mso-add-space:auto;
  line-height:normal">email@test.com</p>
  </td>
 </tr>
</tbody></table>

<p class="MsoNormal" style="margin-bottom:0cm;margin-bottom:0cm;margin-top:0cm;
mso-margin-bottom-alt:8.0pt;mso-margin-top-alt:0cm;mso-add-space:auto"><o:p>&nbsp;</o:p></p>

<p class="MsoNormal"><o:p>&nbsp;</o:p></p>

<p class="MsoNormal"><o:p>&nbsp;</o:p></p>

</div>




</body>
