pageextension 63082 "EMTRM Posted Expenses Ext" extends "CEM Posted Expenses"
{
    actions
    {
        addafter(FindEntries)
        {
            action(ExpenseTransactions)
            {
                ApplicationArea = All;
                Caption = 'Show Expense Entries';
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "CEM Expense Match";
                ToolTip = 'Show Expense Entries matched with bank transactions.';
            }
        }
    }
}