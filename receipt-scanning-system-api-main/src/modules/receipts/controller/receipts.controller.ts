import { OptionParams } from './../../shared/interfaces/options-params.interface';
import { Body, Controller, Delete, Get, Param, Post, Put, Req } from '@nestjs/common';
import { ReceiptsService } from '../service/receipts.service';
import { ReceiptModel } from '../model/receipt.model';

@Controller('receipts')
export class ReceiptsController {
    constructor(
        private _receipts: ReceiptsService,
    ) { }

    @Get()
    async findAll(@Req() req: any) {
        const options: OptionParams = {
            s: JSON.stringify({
                $and: [
                    { created_by: req.user.user_id }
                ]
            })
        };
        return await this._receipts.findAll(options);
    }

    @Get('actions/group-by-date/:searchText')
    async groupByDate(@Req() req: any, @Param('searchText') searchText: string) {
        return await this._receipts.groupByDate(req.user.user_id, searchText);
    }

    @Get('actions/group-by-type/:type')
    async groupByType(@Req() req: any, @Param('type') type: string) {
        return await this._receipts.groupByType(req.user.user_id, Number(type) ?? 1);
    }

    @Get(':userId')
    async findOne(@Param('receiptId') receiptId: string) {
        return await this._receipts.findOne(receiptId);
    }

    @Post()
    async create(@Req() req: any, @Body() data: ReceiptModel) {
        data.created_by = req.user.user_id;
        return await this._receipts.create(data);
    }

    @Put(':receiptId')
    async update(@Param('receiptId') receiptId: string, @Body() data: ReceiptModel) {
        return await this._receipts.update(receiptId, data);;
    }

    @Delete(':receiptId')
    async delete(@Param('receiptId') receiptId: string) {
        return await this._receipts.delete(receiptId);
    }
}
