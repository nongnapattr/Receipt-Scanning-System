import { Schema } from 'mongoose';

export const ReceiptSchema = new Schema(
    {
        receipt_name: String,
        receipt_date: Date,
        receipt_total: String,
        receipt_type: String,
        receipt_image: String,
        created_by: String,
    },
    {
        timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' },
    },
);
