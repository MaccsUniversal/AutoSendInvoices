codeunit 99007 "Send UK Invoices"
{
    Permissions = tabledata "Email Related Record" = RMI;
    trigger OnRun()
    begin
        SendInvoices();
    end;

    local procedure GetParameters(SalesInvoiceNo: Code[20]) SalesInvRepParam: Text
    begin
        SalesInvRepParam := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Standard Sales - Invoice" id="1306"><Options><Field name="LogInteraction">false</Field><Field name="DisplayAssemblyInformation">false</Field><Field name="DisplayShipmentInformation">false</Field><Field name="DisplayAdditionalFeeNote">false</Field><Field name="HideLinesWithZeroQuantity">false</Field></Options><DataItems><DataItem name="Header">VERSION(1) SORTING(Field3) WHERE(Field3=1(' + SalesInvoiceNo + '))</DataItem><DataItem name="Line">VERSION(1) SORTING(Field3,Field4)</DataItem><DataItem name="ShipmentLine">VERSION(1) SORTING(Field1,Field2,Field3)</DataItem><DataItem name="AssemblyLine">VERSION(1) SORTING(Field2,Field3)</DataItem><DataItem name="WorkDescriptionLines">VERSION(1) SORTING(Field1)</DataItem><DataItem name="VATAmountLine">VERSION(1) SORTING(Field5,Field9,Field10,Field13,Field16)</DataItem><DataItem name="VATClauseLine">VERSION(1) SORTING(Field5,Field9,Field10,Field13,Field16)</DataItem><DataItem name="ReportTotalsLine">VERSION(1) SORTING(Field1)</DataItem><DataItem name="LineFee">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PaymentReportingArgument">VERSION(1) SORTING(Field1)</DataItem><DataItem name="LeftHeader">VERSION(1) SORTING(Field1)</DataItem><DataItem name="RightHeader">VERSION(1) SORTING(Field1)</DataItem><DataItem name="LetterText">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Totals">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ContractBillingDetailsMapping">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ContractBillingDetailsGrouping">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ContractBillingDetails">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ItemAttribute">VERSION(1) SORTING(Field1,Field2)</DataItem></DataItems></ReportParameters>';
        exit(SalesInvRepParam);
    end;

    local procedure FilterInvoices() SalesInvHdr: Record "Sales Invoice Header"
    var
        CustomerNoFilter: Text;
        CustomerPostingGroupFilter: Text;
        PostingDate: Date;
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        IsHandled := false;
        OnBeforeFilterInvoices(CustomerNoFilter, CustomerPostingGroupFilter, PostingDate, SalesInvHdr, IsHandled);
        if IsHandled then
            exit(SalesInvHdr);
        CustomerNoFilter := '<>LEM*';
        CustomerPostingGroupFilter := '<>NON NOTIFY|UK*';
        PostingDate := Today() - 1;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetFilter("Sell-to Customer No.", CustomerNoFilter);
        SalesInvoiceHeader.SetFilter("Customer Posting Group", CustomerPostingGroupFilter);
        SalesInvoiceHeader.SetFilter("Posting Date", Format(PostingDate));
        SalesInvoiceHeader.FindSet();
        SalesInvHdr.Copy(SalesInvoiceHeader);
        OnAfterFilterInvoices(SalesInvHdr);
        exit(SalesInvHdr);
    end;

    local procedure GetReportSelection() SelectedReport: Record "Report Selections"
    var
        ReportSelection: Record "Report Selections";
    begin
        ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Invoice");
        ReportSelection.FindSet();
        ReportSelection.SetRange("Report ID", ReportSelection."Report ID");
        ReportSelection.FindSet();
        SelectedReport.Copy(ReportSelection);
    end;

    local procedure SendInvoices()
    var
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        TempBlob: Codeunit "Temp Blob";
        Filename: Text;
        ReportSelection2: Record "Report Selections";
        OutStr: OutStream;
        InStr: InStream;
        MailMgt: Codeunit "Mail Management";
        EmailRelatedRecord: Record "Email Related Record";
        EmailManagement: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailBody: Codeunit "Auto Send Email Body";
    begin
        IsHandled := false;
        OnBeforeSendInvoices(IsHandled);
        if IsHandled then
            exit;
        SalesInvoiceHeader2 := FilterInvoices();
        ReportSelection2 := GetReportSelection();
        OnAfterSetFilterAndSelections(SalesInvoiceHeader2, ReportSelection2);
        repeat
            EmailRelatedRecord.Reset();
            EmailRelatedRecord.SetRange("System Id", SalesInvoiceHeader2.SystemId);
            if not EmailRelatedRecord.FindSet() then begin
                if (SalesInvoiceHeader2."Sell-to E-Mail" = '') then
                    continue;

                MailMgt.CheckValidEmailAddresses(SalesInvoiceHeader2."Sell-to E-Mail");
                Filename := StrSubstNo('Sales Invoice_%1.pdf', SalesInvoiceHeader2."No.");
                TempBlob.CreateOutStream(OutStr);
                Report.SaveAs(ReportSelection2."Report ID", GetParameters(SalesInvoiceHeader2."No."), ReportFormat::Pdf, OutStr);
                TempBlob.CreateInStream(InStr);
                EmailMessage.Create(SalesInvoiceHeader2."Sell-to E-Mail",
                    Filename,
                    EmailBody.GetEmailBody(SalesInvoiceHeader2));
                EmailMessage.AddAttachment(Filename, 'application/pdf', InStr);
                if EmailManagement.Send(EmailMessage) then begin
                    EmailRelatedRecord.Init();
                    EmailRelatedRecord."Email Message Id" := EmailMessage.GetId();
                    EmailRelatedRecord."Table Id" := Database::"Sales Invoice Header";
                    EmailRelatedRecord."System Id" := SalesInvoiceHeader2.SystemId;
                    EmailRelatedRecord.Insert();
                end;
            end;
        until SalesInvoiceHeader2.Next <= 0;
    end;

    var
        IsHandled: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFilterInvoices(var CustomerNoFilter: Text; var CustomerPostingGroupFilter: Text; var PostingDate: Date; var SalesInvHdr: Record "Sales Invoice Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendInvoices(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilterAndSelections(var SalesInvoiceHeader2: Record "Sales Invoice Header"; var ReportSelection2: Record "Report Selections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterInvoices(var SalesInvHdr: Record "Sales Invoice Header")
    begin
    end;
}