import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ReceiptModel } from '../model/receipt.model';
import { MongoCRUD } from './../../shared/mongo-curd';
import { UntilityService } from './../../shared/services/untility.service';

@Injectable()
export class ReceiptsService extends MongoCRUD<ReceiptModel> {
    constructor(
        @InjectModel('receipts') public model: Model<ReceiptModel>,
        private _untilities: UntilityService
    ) {
        super(model);
    }

    async groupByDate(created_by: string, searchText: string) {
        let filter;
        if (searchText !== null && searchText !== '-') {
            filter = { $match: { created_by: created_by, $or: [{ receipt_name: { '$regex': searchText } }, { receipt_type: { '$regex': searchText } }] } };
        } else {
            filter = { $match: { created_by: created_by } };
        }
        const result = await this._model.aggregate([
            filter,
            {
                $group: {
                    _id: {
                        date: { $dateToString: { format: '%Y-%m-%d', date: '$receipt_date' } },
                    },
                    price: { $sum: { $toDouble: '$receipt_total' } },
                    count: { $sum: 1 },
                    items: { $push: "$$ROOT" },
                }
            },
            { $project: { date: '$_id.date', _id: 0, price: 1, count: 1, items: 1 } },
            { $sort: { date: -1 } }
        ]);
        return { data: result, total: result.length };
    }

    async groupByType(created_by: string, type: number) {
        const datenow = this._untilities.getDateTimeUTC(`${new Date().toISOString().split('T')[0]}`, '$lte');
        const dateToday = this._untilities.getDateTimeUTC(`${new Date().toISOString().split('T')[0]}`, '$gte');
        const dateWeek = this._untilities.getDateTimeUTC(`${new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}`, '$gte');
        const dateMonth = this._untilities.getDateTimeUTC(`${new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}`, '$gte');
        const dateYear = this._untilities.getDateTimeUTC(`${new Date(Date.now() - 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}`, '$gte');
        const result = await this._model.aggregate([
            {
                $match: {
                    created_by: created_by,
                    receipt_date: { '$gte': type === 1 ? dateToday : type === 2 ? dateWeek : type === 3 ? dateMonth : dateYear, '$lte': datenow },
                }
            },
            {
                $group: {
                    _id: {
                        type: '$receipt_type',
                    },
                    price: { $sum: { $toDouble: '$receipt_total' } },
                }
            },
            { $project: { type: '$_id.type', _id: 0, price: 1, count: 1, items: 1 } },
            { $sort: { date: -1 } }
        ]);
        return { data: result, total: result.length };
    }
}
