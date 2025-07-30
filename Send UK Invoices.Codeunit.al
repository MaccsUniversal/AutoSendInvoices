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
        JsonObj.ReadFrom(ParamterString);
        CustomerNoFilter := JsonObj.GetText('Customer No.');
        CustomerPostingGroupFilter := JsonObj.GetText('Customer Posting Group');
        OffsetDays := JsonObj.GetInteger('OffsetDays');
        TestEmail := JsonObj.GetText('Test Email');
    end;

    local procedure GetParameters(SalesInvoiceNo: Code[20]) SalesInvRepParam: Text
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
        TempBlob: Codeunit "Temp Blob";
        Filename: Text;
        OutStr: OutStream;
        InStr: InStream;
        MailMgt: Codeunit "Mail Management";
        EmailRelatedRecord: Record "Email Related Record";
        EmailManagement: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailBody: Codeunit "Auto Send Email Body";
        EmailToUse: Text;
    begin
        EmailToUse := TestEmail;
        IsHandled := false;
        OnBeforeSendInvoices(FilteredSalesInvoiceHeaders, SelectedReport, IsHandled);
        if IsHandled then
            exit;
        repeat
            if TestEmail = '' then begin
                EmailToUse := FilteredSalesInvoiceHeaders."Sell-to E-Mail";
            end;

            EmailRelatedRecord.Reset();
            EmailRelatedRecord.SetRange("System Id", FilteredSalesInvoiceHeaders.SystemId);
            if not EmailRelatedRecord.FindSet() then begin
                if (EmailToUse = '') then
                    continue;

                MailMgt.CheckValidEmailAddresses(EmailToUse);
                Filename := StrSubstNo('Sales Invoice_%1.pdf', FilteredSalesInvoiceHeaders."No.");
                TempBlob.CreateOutStream(OutStr);
                Report.SaveAs(SelectedReport."Report ID", GetParameters(FilteredSalesInvoiceHeaders."No."), ReportFormat::Pdf, OutStr);
                TempBlob.CreateInStream(InStr);
                EmailMessage.Create(EmailToUse,
                    Filename,
                    EmailBody.GetEmailBody(FilteredSalesInvoiceHeaders));
                EmailMessage.AddAttachment(Filename, 'application/pdf', InStr);
                if EmailManagement.Send(EmailMessage) then begin
                    EmailRelatedRecord.Init();
                    EmailRelatedRecord."Email Message Id" := EmailMessage.GetId();
                    EmailRelatedRecord."Table Id" := Database::"Sales Invoice Header";
                    EmailRelatedRecord."System Id" := FilteredSalesInvoiceHeaders.SystemId;
                    EmailRelatedRecord."Relation Type" := "Email Relation Type"::"Related Entity";
                    EmailRelatedRecord."Relation Origin" := "Email Relation Origin"::"Compose Context";
                    EmailRelatedRecord.Insert();
                end;
            end;
        until FilteredSalesInvoiceHeaders.Next <= 0;
        OnAfterSendInvoices(FilteredSalesInvoiceHeaders, SelectedReport);
    end;

    var
        IsHandled: Boolean;
        TestEmail: Text;
        JsonObj: JsonObject;
        CustomerNoFilter: Text;
        CustomerPostingGroupFilter: Text;
        OffsetDays: Integer;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFilterInvoices(var SalesInvHdr: Record "Sales Invoice Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendInvoices(var FilteredSalesInvoiceHeaders: Record "Sales Invoice Header"; var SelectedReport: Record "Report Selections"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSendInvoices(var SalesInvHdr: Record "Sales Invoice Header"; var ReportSelection: Record "Report Selections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterInvoices(var SalesInvHdr: Record "Sales Invoice Header")
    begin
    end;
}