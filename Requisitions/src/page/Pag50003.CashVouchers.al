/// <summary>
/// Page Cash Vouchers (ID 50003).
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
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Budget Code"; Rec."Budget Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = StatusEdit;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Prepared by"; Rec."Prepared by")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = All;
                }
                field("Payment Voucher Details Total"; Rec."Payment Voucher Details Total")
                {
                    ApplicationArea = All;
                }
                field("Payment Voucher Lines Total"; Rec."Payment Voucher Lines Total")
                {
                    ApplicationArea = All;
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

