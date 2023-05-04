/// <summary>
/// Page Cash Vouchers (ID 50098).
/// </summary>
page 50003 "Cash Vouchers"
{
    // version MAG

    Caption = 'Cash Vouchers';
    CardPageID = "Cash Voucher";
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";
    SourceTableView = WHERE("Document Type" = FILTER("Cash Voucher"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("No."; Rec."No.")
                {
                }
                field("Budget Code"; Rec."Budget Code")
                {
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    Editable = StatusEdit;
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field(Comment; Rec.Comment)
                {
                    Visible = false;
                }
                field("Prepared by"; Rec."Prepared by")
                {
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
                field(Payee; Rec.Payee)
                {
                }
                field("Payment Voucher Details Total"; Rec."Payment Voucher Details Total")
                {
                }
                field("Payment Voucher Lines Total"; Rec."Payment Voucher Lines Total")
                {
                }
            }
        }
    }

    actions
    {

    }

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        PurchPaySetup.GET;
        PurchPaySetup.TESTFIELD("Cash Voucher Nos.");
        Rec."No." := NoSeriesMgt.GetNextNo(PurchPaySetup."Cash Voucher Nos.", TODAY, TRUE);
        Rec.VALIDATE("Document Type", Rec."Document Type"::"Cash Voucher");
        Rec.VALIDATE("Prepared by", USERID);
        Rec.VALIDATE("Posting Date", WORKDATE);
        GeneralLedgerSetup.GET;
        GeneralLedgerSetup.TESTFIELD("Approved Budget");
        Rec.VALIDATE("Budget Code", GeneralLedgerSetup."Approved Budget");
    end;

    trigger OnOpenPage();
    begin
        Rec.FILTERGROUP(2);
        Rec.SETRANGE("Prepared by", USERID);
        Rec.FILTERGROUP(0);
    end;

    var
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        GeneralLedgerSetup: Record "General Ledger Setup";
        recUserSetup: Record "User Setup";
        StatusEdit: Boolean;
    //LF Edit Voucher Status for trials
    local procedure OnAfterGetCurrRecord();
    begin
        xRec := Rec;
        //RBM 040604
        IF recUserSetup.GET(USERID) THEN
            IF recUserSetup."Edit Advance Status" THEN BEGIN
                StatusEdit := TRUE;
            END
            ELSE BEGIN
                StatusEdit := FALSE;
            END;
    END;
}

