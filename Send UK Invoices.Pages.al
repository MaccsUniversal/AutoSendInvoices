page 99015 "Send Invoices UK"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    // SourceTable = "Auto Send UK Invoices";
    InsertAllowed = false;
    ModifyAllowed = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group("Email Body")
            {
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                var
                    SendInvoices: Codeunit "Send UK Invoices";
                    JobQueue: Record "Job Queue Entry";
                begin
                    SendInvoices.Run(JobQueue);
                end;
            }
        }
    }

}