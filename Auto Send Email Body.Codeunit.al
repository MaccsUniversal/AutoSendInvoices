codeunit 60103 "Auto Send Email Body"
{
    procedure GetEmailBody(var SalesInvHdr: Record "Sales Invoice Header") Body: Text
    var
        IsHandled: Boolean;
        NewBody: Text;
    begin
        IsHandled := false;
        OnBeforeGetEmailBody(IsHandled, NewBody, SalesInvHdr);
        if IsHandled then
            exit(Body);
        Body := 'Dear customer,' +
                ' Thank you for your recent order.  Please find your invoice ' + SalesInvHdr."No." + ' attached. Please ensure that and price, delivery or other invoice discrepancy is notified by email within 48 HOURS of the invoice date to credit@e-2go.net If you have already paid for your order in full, the invoice is for information only. Otherwise please can you pay by the stated due date to the bank details quoted on the invoice.';
        OnAfterGetEmailBody(Body, SalesInvHdr);
        exit(Body);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetEmailBody(var IsHandled: Boolean; var NewBody: Text; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetEmailBody(var Body: Text; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;
}