pageextension 63080 "EMADV GL Open Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Expense Entry No."; Rec."Expense Entry No.")
            {
                ApplicationArea = All;
                Caption = 'Expense Entry No.';
                ToolTip = 'Shows the Expense Entry No. that this posted G/L Entry is related to.';
            }
        }
    }
}