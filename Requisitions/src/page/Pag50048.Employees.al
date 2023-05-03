/// <summary>
/// Page "Employees" (ID 50130).
/// </summary>
page 50048 Employees
{
    Caption = 'Employees';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    PageType = List;
    SourceTable = Employee;
    SourceTableView = WHERE(Status = FILTER(Active),
    "Employment Type" = FILTER(Permanent));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(FullName; FullName)
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the full name of the employee.';
                    Visible = false;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = BasicHR;
                    NotBlank = true;
                    ToolTip = 'Specifies the employee''s first name.';
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s middle name.';
                    Visible = false;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = BasicHR;
                    NotBlank = true;
                    ToolTip = 'Specifies the employee''s last name.';
                }
                field(Initials; Initials)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee''s initials.';
                    Visible = false;
                }
                field("Job Title"; "Job Title")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s job title.';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the postal code.';
                    Visible = false;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Company Phone No.';
                    ToolTip = 'Specifies the employee''s telephone number.';
                    Visible = false;
                }
                field(Extension; Extension)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s telephone extension.';
                    Visible = false;
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Private Phone No.';
                    ToolTip = 'Specifies the employee''s private telephone number.';
                    Visible = false;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Private Email';
                    ToolTip = 'Specifies the employee''s private email address.';
                    Visible = false;
                }
                field("Statistics Group Code"; "Statistics Group Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a statistics group code to assign to the employee for statistical purposes.';
                    Visible = false;
                }
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a resource number for the employee.';
                    Visible = false;
                }
                field("Privacy Blocked"; "Privacy Blocked")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies whether to limit access to data for the data subject during daily operations. This is useful, for example, when protecting data from changes while it is under privacy review.';
                    Visible = false;
                }
                field("Search Name"; "Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies if a comment has been entered for this entry.';
                    Visible = false;
                }
            }
        }
    }
}

