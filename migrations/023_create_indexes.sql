-- This migration creates indexes on the invoice and invoice_line tables to improve query performance.
-- The idx_invoice_invoice_date index is created on the invoice_date column of the invoice table.
-- The idx_invoice_line_track_id index is created on the track_id column of the invoice_line table.

CREATE INDEX IF NOT EXISTS idx_invoice_invoice_date_date
ON invoice ((invoice_date::date));

CREATE INDEX IF NOT EXISTS idx_invoice_line_track_id
ON invoice_line (track_id);