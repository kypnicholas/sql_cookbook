 -- Create an expression index on `invoice(invoice_date::date)` to improve query performance for date range filters.

CREATE INDEX IF NOT EXISTS idx_invoice_date_cast 
ON invoice ((invoice_date::date));
