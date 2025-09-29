pageextension 63083 "EMTRM Gen. Ledger Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Bank Transaction Entry No."; Rec."Bank Transaction Entry No.")
            {
                ApplicationArea = All;
                Caption = 'Bank Transaction Entry No.';
                ToolTip = 'The entry number of the bank transaction linked to this G/L entry.';
                Editable = false;
            }
        }
    }
}
