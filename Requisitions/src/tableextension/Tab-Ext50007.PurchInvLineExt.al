/// <summary>
/// TableExtension Purchase Line Ext (ID 50063) extends Record Purchase Line.
/// </summary>
tableextension 50007 "Purch Inv Line Ext" extends "Purch. Inv. Line"
{
    fields
    {
        // Add changes to table fields here
        field(50300; "Qty. Requested"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(50301; "Request-By No."; Code[20])
        {
            TableRelation = Employee."No.";
        }
        field(50302; "Request-By Name"; Text[50])
        {
        }
        field(50303; "G/L Expense A/c"; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(50304; "Pay to Type"; Option)
        {
            OptionCaption = '" ,Vendor,Staff,Other"';
            OptionMembers = " ",Vendor,Staff,Other;
        }
        field(50305; "Pay to No."; Code[20])
        {
            TableRelation = IF ("Pay to Type" = FILTER(Vendor)) Vendor."No."
            ELSE
            IF ("Pay to Type" = FILTER(Staff)) Employee."No.";

            trigger OnValidate();
            var
                EmpRec: Record Employee;
                VendRec: Record Vendor;
            begin
                CASE "Pay to Type" OF
                    "Pay to Type"::Vendor:
                        BEGIN
                            IF "Pay to No." <> '' THEN BEGIN
                                VendRec.GET("Pay to No.");
                                "Pay to Name" := VendRec.Name;
                            END;
                        END;
                    "Pay to Type"::Staff:
                        BEGIN
                            IF "Pay to No." <> '' THEN BEGIN
                                EmpRec.GET("Pay to No.");
                                "Pay to Name" := EmpRec.FullName;
                            END;
                        END;
                END;
            end;
        }
        field(50306; "Pay to Name"; Text[80])
        {
        }
        field(50307; "External Document No."; Code[20])
        {
        }
        field(50309; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionCaption = '" ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund"';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(50310; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';

            trigger OnLookup();
            var
                PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
                AccType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset";
                AccNo: Code[20];
            begin
            end;
        }
        field(50311; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';
        }
        field(50312; "Invoiced Amount"; Decimal)
        {
            Description = 'Used in the LPO pages list: JCK 13.08.12';
        }
        field(50313; "WHT Code"; Code[20])
        {
        }
        field(50330; "Include in Purch. Order"; Boolean)
        {
        }
        field(50331; "Inventory Charge A/c"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50332; "Total Cost"; Decimal)
        {
        }
        field(50335; "Control Account"; Code[20])
        {
            Description = 'Holds a control account for an Item or Fixed Asset Purchase line Commitment';
            Editable = false;
            TableRelation = "G/L Account"."No.";
        }
        field(50336; "Commitment Entry No."; Integer)
        {
            Description = 'Identifies a line that has been commited';
        }
        field(50337; "Direct Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FIELDNO("Direct Unit Cost (LCY)"));
            Caption = 'Direct Unit Cost (LCY)';
            Description = 'Handles the LCY Amount for Direct Unit Cost';
            Editable = false;
        }
        field(50338; "Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FIELDNO("Line Amount (LCY)"));
            Caption = 'Line Amount (LCY)';
            Description = 'Handles the LCY Amount for Line Amount';
            Editable = false;

        }
        field(50339; "Doc. Created By"; Code[50])
        {
        }
        field(50340; "Doc. Creation Date"; Date)
        {
        }
        field(50341; "Advance Code"; Code[20])
        {
            Description = 'Staff Members'' Codes for tracking advances and loans';
            TableRelation = "Staff Advances";
        }
        field(50342; "Commitment Budget"; Code[10])
        {
            TableRelation = "G/L Budget Name".Name;
        }
        field(50343; "non contract"; Boolean)
        {
            Description = 'rRe';
        }
        field(50344; "Transfer to Item Jnl"; Boolean)
        {
        }
        field(50345; "Make Purchase Req."; Boolean)
        {
        }
        field(50346; "Qty To Transfer to Item Jnl"; Decimal)
        {

            trigger OnValidate();
            begin
                //ReqnHeader2.GET("Document Type","Document No.");
                //ReqnHeader2.TESTFIELD(Status,ReqnHeader2.Status::Open);
            end;
        }
        field(50347; "Qty To Make Purch. Req."; Decimal)
        {

            trigger OnValidate();
            begin
                //ReqnHeader2.GET("Document Type","Document No.");
                //ReqnHeader2.TESTFIELD(Status,ReqnHeader2.Status::Open);
            end;
        }
        field(50348; "Transferred To Item Jnl"; Boolean)
        {
            Editable = false;
        }
        field(50349; "Transferred To Purch. Req."; Boolean)
        {
            Editable = false;
        }
        field(50350; Currentbeingused; Boolean)
        {
        }
        field(50351; "Total Qty To Item Jnl"; Decimal)
        {
            Editable = false;
        }
        field(50352; "Total Qty To Purch. Req"; Decimal)
        {
            Editable = false;
        }
        field(50353; "Req. Reserved Quantity"; Decimal)
        {
            CalcFormula = - Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                   "Source Ref. No." = FIELD("Line No."),
                                                                   //    "Source Type" = CONST(39006291),IE
                                                                   //"Source Subtype" = FIELD("Document Type"),
                                                                   "Reservation Status" = CONST(Reservation)));
            FieldClass = FlowField;
        }
        field(50354; "Qty Returned"; Decimal)
        {

            trigger OnValidate();
            var
                lvStoreReturn: Record "NFL Requisition Line";
            begin
            end;
        }
        field(50355; "Archive No."; Code[20])
        {
        }
        field(50356; "Qty. Not Returned"; Decimal)
        {

            trigger OnValidate();
            var
                lvStoreReturn: Record "NFL Requisition Line";
            begin
            end;
        }
        field(50357; "Store Issue Line No"; Integer)
        {
        }
    }

    var
        myInt: Integer;
}