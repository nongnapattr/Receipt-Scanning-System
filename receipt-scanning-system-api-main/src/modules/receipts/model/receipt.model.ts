import { Timestamps } from './../../shared/interfaces/timestamps.model';

export class ReceiptModel extends Timestamps {
    receipt_name: string;
    receipt_date: Date;
    receipt_total?: string;
    receipt_type?: string;
    receipt_image?: string;
}