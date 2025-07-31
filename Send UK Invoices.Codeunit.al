codeunit 99009 "Send UK Invoices"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "Email Related Record" = RMI;
    trigger OnRun()
    begin
        SetValues(Rec."Parameter String");
        FilterInvoices();
    end;

    local procedure SetValues(var ParamterString: Text)
    begin
        JsonObj.ReadFrom('{"Invoice No.": "","Customer No.": "<>LEM*","Customer Posting Group": "NON NOTIFY|UK*","OffsetDays": 50,"Test Email": "itadmin@e-2go.net"}');
        SalesInvoiceNo := JsonObj.GetText('Invoice No.');
        CustomerNoFilter := JsonObj.GetText('Customer No.');
        CustomerPostingGroupFilter := JsonObj.GetText('Customer Posting Group');
        OffsetDays := JsonObj.GetInteger('OffsetDays');
        TestEmail := JsonObj.GetText('Test Email');
    end;

    local procedure GetReportParameters(SalesInvoiceNo: Code[20]) SalesInvRepParam: Text
    begin
        SalesInvRepParam := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Standard Sales - Invoice" id="1306"><Options><Field name="LogInteraction">false</Field><Field name="DisplayAssemblyInformation">false</Field><Field name="DisplayShipmentInformation">false</Field><Field name="DisplayAdditionalFeeNote">false</Field><Field name="HideLinesWithZeroQuantity">false</Field></Options><DataItems><DataItem name="Header">VERSION(1) SORTING(Field3) WHERE(Field3=1(' + SalesInvoiceNo + '))</DataItem><DataItem name="Line">VERSION(1) SORTING(Field3,Field4)</DataItem><DataItem name="ShipmentLine">VERSION(1) SORTING(Field1,Field2,Field3)</DataItem><DataItem name="AssemblyLine">VERSION(1) SORTING(Field2,Field3)</DataItem><DataItem name="WorkDescriptionLines">VERSION(1) SORTING(Field1)</DataItem><DataItem name="VATAmountLine">VERSION(1) SORTING(Field5,Field9,Field10,Field13,Field16)</DataItem><DataItem name="VATClauseLine">VERSION(1) SORTING(Field5,Field9,Field10,Field13,Field16)</DataItem><DataItem name="ReportTotalsLine">VERSION(1) SORTING(Field1)</DataItem><DataItem name="LineFee">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PaymentReportingArgument">VERSION(1) SORTING(Field1)</DataItem><DataItem name="LeftHeader">VERSION(1) SORTING(Field1)</DataItem><DataItem name="RightHeader">VERSION(1) SORTING(Field1)</DataItem><DataItem name="LetterText">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Totals">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ContractBillingDetailsMapping">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ContractBillingDetailsGrouping">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ContractBillingDetails">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ItemAttribute">VERSION(1) SORTING(Field1,Field2)</DataItem></DataItems></ReportParameters>';
        exit(SalesInvRepParam);
    end;

    local procedure FilterInvoices()
    var
        PostingDate: Date;
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        IsHandled := false;
        OnBeforeFilterInvoices(SalesInvoiceHeader, IsHandled);
        if IsHandled then
            GetReportSelection(SalesInvoiceHeader);
        PostingDate := Today() - OffsetDays;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetFilter("No.", SalesInvoiceNo);
        SalesInvoiceHeader.SetFilter("Sell-to Customer No.", CustomerNoFilter);
        SalesInvoiceHeader.SetFilter("Customer Posting Group", CustomerPostingGroupFilter);
        SalesInvoiceHeader.SetFilter("Posting Date", Format(PostingDate));
        SalesInvoiceHeader.FindSet();
        OnAfterFilterInvoices(SalesInvoiceHeader);
        GetReportSelection(SalesInvoiceHeader);
    end;

    local procedure GetReportSelection(var FilteredSalesInvoiceHeader: Record "Sales Invoice Header")
    var
        ReportSelection: Record "Report Selections";
    begin
        ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Invoice");
        ReportSelection.FindSet();
        ReportSelection.SetRange("Report ID", ReportSelection."Report ID");
        ReportSelection.FindSet();
        SendInvoices(FilteredSalesInvoiceHeader, ReportSelection);
    end;

    local procedure SendInvoices(var FilteredSalesInvoiceHeaders: Record "Sales Invoice Header"; var SelectedReport: Record "Report Selections")
    var
        EmailToUse: Text;
        MessageId: Guid;
        EmailRelatedRecordExists: Boolean;
        MailMgt: Codeunit "Mail Management";
    begin
        EmailToUse := TestEmail;
        repeat
            if TestEmail = '' then
                EmailToUse := FilteredSalesInvoiceHeaders."Sell-to E-Mail";
            if EmailToUse = '' then
                continue;
            MailMgt.CheckValidEmailAddresses(EmailToUse);
            EmailRelatedRecordExists := CheckEmailRelatedRecords(FilteredSalesInvoiceHeaders.SystemId);
            if not EmailRelatedRecordExists then begin
                MessageId := SendEmailMsg(EmailToUse, FilteredSalesInvoiceHeaders, SelectedReport);
                if not IsNullGuid(MessageId) then begin
                    UpdateEmailRelatedRecords(MessageId, FilteredSalesInvoiceHeaders.SystemId);
                end;
            end;
        until FilteredSalesInvoiceHeaders.Next <= 0;
    end;

    local procedure UpdateEmailRelatedRecords(var MsgId: Guid; var SalesInvSystemId: Guid)
    begin
        EmailRelatedRecord.Init();
        EmailRelatedRecord."Email Message Id" := MsgId;
        EmailRelatedRecord."Table Id" := Database::"Sales Invoice Header";
        EmailRelatedRecord."System Id" := SalesInvSystemId;
        EmailRelatedRecord."Relation Type" := "Email Relation Type"::"Related Entity";
        EmailRelatedRecord."Relation Origin" := "Email Relation Origin"::"Compose Context";
        EmailRelatedRecord.Insert();
    end;

    local procedure CheckEmailRelatedRecords(var SalesInvoiceSystemId: Guid) Found: Boolean
    begin
        EmailRelatedRecord.Reset();
        EmailRelatedRecord.SetRange("System Id", SalesInvoiceSystemId);
        Found := EmailRelatedRecord.FindSet();
        exit(Found);
    end;

    local procedure SendEmailMsg(Recipient: Text; var SalesInvoice: Record "Sales Invoice Header"; var InvoiceReport: Record "Report Selections") EmailMsgId: Guid
    var
        TempBlob: Codeunit "Temp Blob";
        Filename: Text;
        OutStr: OutStream;
        InStr: InStream;
        EmailManagement: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailBody: Codeunit "Auto Send Email Body";
    begin
        IsHandled := false;
        OnBeforeSendEmailMsg(SalesInvoice, InvoiceReport, IsHandled);
        if IsHandled then
            exit(EmailMsgId);

        Clear(OutStr);
        Clear(InStr);
        Clear(EmailMessage);
        Filename := StrSubstNo('Sales Invoice_%1', SalesInvoice."No.");
        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(InvoiceReport."Report ID", GetReportParameters(SalesInvoice."No."), ReportFormat::Pdf, OutStr) then
            exit(EmailMsgId);
        EmailMessage.Create(Recipient, Filename, EmailBody.GetEmailBody(SalesInvoice), true);
        TempBlob.CreateInStream(InStr);
        EmailMessage.AddAttachment(Filename + '.pdf', 'application/pdf', InStr);
        if EmailManagement.Send(EmailMessage) then
            EmailMsgId := EmailMessage.GetId();
        OnAfterSendEmailMsg(SalesInvoice, InvoiceReport);
        exit(EmailMsgId);
    end;

    var
        IsHandled: Boolean;
        TestEmail: Text;
        JsonObj: JsonObject;
        CustomerNoFilter: Text;
        CustomerPostingGroupFilter: Text;
        OffsetDays: Integer;
        SalesInvoiceNo: Text;
        EmailRelatedRecord: Record "Email Related Record";

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFilterInvoices(var SalesInvHdr: Record "Sales Invoice Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendEmailMsg(var FilteredSalesInvoiceHeaders: Record "Sales Invoice Header"; var SelectedReport: Record "Report Selections"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSendEmailMsg(var SalesInvHdr: Record "Sales Invoice Header"; var ReportSelection: Record "Report Selections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterInvoices(var SalesInvHdr: Record "Sales Invoice Header")
    begin
    end;
}