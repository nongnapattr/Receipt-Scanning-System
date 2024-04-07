import { HttpException, HttpStatus } from "@nestjs/common";
import { OptionParams } from "./interfaces/options-params.interface";
import * as _ from 'lodash';
import { Model } from "mongoose";

export class MongoCRUD<T> {

    public modelName: string;
    protected _model: Model<T>;
    operatorGreaterLess = ['$gte', '$gt', '$lte', '$lt', '$ne', '$regex'];
    search = {};
    sort = {};

    constructor(public model: Model<T>) {
        this.modelName = model.modelName;
        this._model = model;
    }
    // Example
    // 0-4.    page 1
    // 5-9.    page 2
    // 10-14   page 3
    // (0-1) * 5 = 10

    // (page - 1) * limit = offset
    // (2-1) * 5 = 10
    async findAll(options?: OptionParams): Promise<any> {
        try {
            this.search = {};
            this.sort = {};
            if (!_.isEmpty(options)) {
                this.checkOptionEmpty(options);
                if (!_.isEmpty(options.sort)) {
                    this.sort = JSON.parse(options.sort);
                }

                if (!_.isEmpty(options.s)) {
                    this.search = await this.getMatchFilter(null, options);
                }

                if ((options.page || options.offset) && options.limit) {
                    if (options.page) {
                        options.offset = (options.page - 1) * options.limit;
                    }
                    const results = await this.findAllPagination(options);
                    const total = await this.countAllDocument(options);
                    const { page, page_total } = this.getPagination(options, total);

                    return {
                        data: results,
                        length: results.length,
                        page_total,
                        page,
                        total
                    }
                } else if (options.offset) {
                    const results = await this._model.find({ is_delete: { $ne: true } }).find(this.search, null).skip(options.offset).sort(this.sort);
                    const total = await this.countAllDocument(options);
                    return { data: results, total };
                } else if (options.limit) {
                    const results = await this._model.find({ is_delete: { $ne: true } }).find(this.search, null).limit(options.limit).sort(this.sort);
                    const total = await this.countAllDocument(options);
                    return { data: results, total };
                } else {
                    return await this.findAllDocument();
                }
            } else {
                return await this.findAllDocument();
            }


        } catch (ex) {
            throw new HttpException(`Exception findAll ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    private async countAllDocument(options: OptionParams): Promise<number> {
        if (!_.isEmpty(options.s)) {
            return await this._model.find({ is_delete: { $ne: true } }).find(this.search, null).count();
        }
        return await this._model.find({ is_delete: { $ne: true } }).count();
    }

    private async findAllDocument() {
        const results = await this._model.find({ is_delete: { $ne: true } }).find(this.search).sort(this.sort);
        return { data: results, total: results.length };
    }

    private async findAllPagination(options: OptionParams) {
        return await this._model.find({ is_delete: { $ne: true } }).find(this.search, null).skip(options.offset).limit(options.limit).sort(this.sort);
    }

    /**
    * API Call Example http://localhost:3000/api/v1/shops/5fb61c523bc0f652ddfc3fcc/orders?offset=0&limit=20&s={"$and": [{"order_date": {"$gte": "2021-02-02","$lte": "2021-02-02"}},{"order_status": 1}]}
    * @param prefix 
    * @param options
    * Ref. destruction https://attacomsian.com/blog/javascript-convert-array-of-objects-to-object 
    */

    async getMatchFilter(prefix: string, options: OptionParams): Promise<any> {
        let isFullText = false;
        if (_.isEmpty(options)) return {};
        if (!_.isEmpty(options.is_full_text)) {
            isFullText = (/true/i).test(options.is_full_text) === true ? true : false
        }
        if (!_.isEmpty(options.s)) {
            try {
                let search = JSON.parse(options.s);
                const operator = Object.keys(search)[0];
                search[operator] = await Promise.all(search[operator].map((element: any) => {
                    const key = Object.keys(element)[0];
                    if (element[key] === '') return;
                    // console.log(`${key} ====> `, element[key], ', ', typeof element[key]);
                    if (element[key] !== null && element[key] !== undefined) {
                        switch (typeof element[key]) {
                            case 'object':
                                for (const operator of Object.keys(element[key])) {
                                    // console.log('Input ====> ', element[key][operator]);
                                    if (!this.invalidOperator(operator) && typeof Number(operator) !== 'number') {
                                        throw new HttpException(`Unknow operator: ${operator}`, HttpStatus.BAD_REQUEST);
                                    } else {
                                        if (element[key][operator].length === 10 || element[key][operator].length === 19) {
                                            element[key][operator] = this.getDateTimeUTC(element[key][operator], operator);
                                        } else {
                                            // Catch when element[key] is { $regex: value }
                                            try {
                                                element[key][operator] = JSON.parse(element[key][operator]);
                                            } catch { }
                                        }
                                    }
                                    // console.log(`result ====> ${operator}   ${element[key][operator]}`);
                                }
                                return { [`${prefix === null ? '' : prefix + '.'}${key}`]: element[key] }
                            case 'number':
                                return { [`${prefix === null ? '' : prefix + '.'}${key}`]: element[key] };
                            default:
                                return isFullText ?
                                    { [`${prefix === null ? '' : prefix + '.'}${key}`]: `${element[key]}` } :
                                    { [`${prefix === null ? '' : prefix + '.'}${key}`]: { $regex: element[key] } };
                        }
                    }
                }));
                // console.log(search[operator]);
                const searchComplete = { [operator]: [] }
                for (const field of search[operator]) {
                    if (field !== undefined && field !== null) {
                        searchComplete[operator].push(field);
                    }
                }
                // console.log(JSON.stringify(searchComplete));
                return searchComplete;
            } catch (ex) {
                console.log(`MongoCRUD<T> Exception getMatchFilter ${this.modelName} ====> ${ex}`);
            }
        }
    }

    private invalidOperator(value: string): boolean {
        return this.operatorGreaterLess.includes(value);
    }


    // example 2021-04-26 00:00:00 or 2021-04-26
    private getDateTimeUTC(date: string, operator: string): Date {
        try {
            if (_.isEmpty(date)) { return; };
            const [searchDate, searchTime] = date.split(' ');
            const [_year, _month, _date] = searchDate.split('-');
            if (searchDate && searchTime) {
                const [searchHour, searchMin, searchSec] = searchTime.split(':');
                return new Date(Number(_year), Number(_month) - 1, Number(_date), Number(searchHour), Number(searchMin), Number(searchSec));
            } else {
                if (operator === '$gte' || operator === '$gt') {
                    return new Date(Number(_year), Number(_month) - 1, Number(_date), 0, 0, 0, 0);
                } else if (operator === '$lte' || operator === '$lt') {
                    return new Date(Number(_year), Number(_month) - 1, Number(_date), 23, 59, 59, 999);
                } else {
                    return new Date(Number(_year), Number(_month) - 1, Number(_date), 0, 0, 0, 0);
                }
            }
        } catch (ex) {
            console.log(`Exception getDateTimeUTC ${this.modelName} ====> ${ex}`);
            return;
        }

    }


    private getPagination(options: OptionParams, total: number): { page: number, page_total: number } {
        const page_total = Math.round(total / options.limit);
        const page = Math.floor((options.offset / options.limit)) + 1;
        return { page_total, page };
    }

    async findOne(id: string | any) {
        try {
            const results = await this._model.findOne({ _id: id, is_delete: { $ne: true } }).exec();
            return results;
        } catch (ex) {
            throw new HttpException(`Exception findOne ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    async create(data: T) {
        try {
            return await this._model.create(data);
        } catch (ex) {
            throw new HttpException(`Exception create ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    async update(id: string | any, data: T) {
        try {
            return await this._model.updateOne({ _id: id }, data, { new: true, upsert: true });
        } catch (ex) {
            throw new HttpException(`Exception update ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    async delete(id: string | any) {
        try {
            return await this._model.deleteOne({ _id: id });
        } catch (ex) {
            throw new HttpException(`Exception delete ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    async safeDelete(id: string | any) {
        try {
            return await this._model.updateOne({ _id: id }, { is_delete: true }, { new: true, upsert: true });
        } catch (ex) {
            throw new HttpException(`Exception safeDelete ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    private checkOptionEmpty(options: OptionParams): OptionParams {
        if (!_.isEmpty(options.offset)) {
            options.offset = Number(options.offset);
        }
        if (!_.isEmpty(options.limit)) {
            options.limit = Number(options.limit);
        }
        if (!_.isEmpty(options.page)) {
            options.page = Number(options.page);
        }
        return options
    }
}