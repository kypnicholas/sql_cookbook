-- Create a functional index on `invoice(invoice_date)` using the `date_trunc` function to optimize queries that group invoices by month.

CREATE INDEX IF NOT EXISTS idx_invoice_date_trunc_month 
ON invoice (date_trunc('month', invoice_date));