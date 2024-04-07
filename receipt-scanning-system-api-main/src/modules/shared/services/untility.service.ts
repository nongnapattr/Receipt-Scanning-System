import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import * as _ from 'lodash';
import { Types } from 'mongoose';
import { Constants } from '../constants';
import { ModelServiceMongoDB } from '../interfaces/model-service.interface';
import { OptionParams } from '../interfaces/options-params.interface';
import * as bcrypt from 'bcryptjs';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UntilityService {
    public serviceName = 'UntilityService';
    operatorGreaterLess = ['$gte', '$gt', '$lte', '$lt', '$ne', '$regex', '$or', '$and'];
    BCRYPT_HASH_ROUND = 8;

    constructor(
        private _httpService: HttpService,
    ) { }

    getDateTimeUTC(date: string, operator: string): Date {
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
            console.log(`Exception getDateTimeUTC ${this.serviceName} ====> ${ex}`);
            return;
        }
    }

    convertDateTimeUTC(date: string): Date {
        try {
            if (_.isEmpty(date)) { return; };
            const [searchDate, searchTime] = date.split(' ');
            const [_year, _month, _date] = searchDate.split('-');
            if (searchDate && searchTime) {
                const [searchHour, searchMin, searchSec] = searchTime.split(':');
                return new Date(Number(_year), Number(_month) - 1, Number(_date), Number(searchHour), Number(searchMin), Number(searchSec));
            }
        } catch (ex) {
            console.log(`Exception getDateTimeUTC ${this.serviceName} ====> ${ex}`);
            return;
        }
    }

    private invalidOperator(value: string): boolean {
        return this.operatorGreaterLess.includes(value);
    }

    private invalidDate(dateStr: string): boolean {
        try {
            return new Date(dateStr) instanceof Date;
        } catch (ex) {
            return false;
        }
    }

    getSort(sort: string): { field: string, cond: number } {
        try {
            if (_.isEmpty(sort)) {
                return { field: 'created_at', cond: 1 }
            };
            let sortCondNumber: number;
            let [sortField, sortCond] = _.isEmpty(sort) ? sort.split(',') : (sort).split(',');
            sortField = sortField.trim();
            sortCondNumber = sortCond === undefined || sortCond.trim() === 'DESC' ? -1 : 1;
            return { field: sortField, cond: sortCondNumber };
        } catch (ex) {
            console.log(`Exception getSort ${this.serviceName} ====> ${ex}`);
            return { field: 'created_at', cond: 1 };
        }
    }

    /**
     * API Call Example http://localhost:3000/api/v1/shops/5fb61c523bc0f652ddfc3fcc/orders?offset=0&limit=20&s={"$and": [{"order_date": {"$gte": "2021-02-02","$lte": "2021-02-02"}},{"order_status": 1}]}
     * @param prefix 
     * @param optionSearch 
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
                // console.log(searchComplete);
                return searchComplete;
            } catch (ex) {
                console.log(`Exception getMatchFilter ${this.serviceName} ====> ${ex}`);
            }
        }
    }

    /**
     * 
     */
    async getMatchFilterFirst(shopId: string, modelServiceMongoDB: ModelServiceMongoDB, options?: OptionParams) {
        try {
            options.limit = !options?.limit ? Constants.LIMIT : Number(options.limit);
            options.offset = !options?.offset ? Constants.OFFSET : Number(options.offset);
            const sort = this.getSort(options.sort);
            const query = [
                { $match: { _id: new Types.ObjectId(shopId) } },
                { $project: { [modelServiceMongoDB.modelName]: 1, _id: 0 } },
                { $unwind: `$${modelServiceMongoDB.modelName}` },
                { $replaceRoot: { newRoot: `$${modelServiceMongoDB.modelName}` } },
                { $sort: { [sort.field]: sort.cond } },
                { $skip: options.offset },
                { $limit: options.limit }
            ];

            const results = await modelServiceMongoDB.modelService.aggregate(query);

            const [{ total }] = await modelServiceMongoDB.modelService.aggregate([
                { $match: { _id: new Types.ObjectId(shopId) } },
                { $project: { total: { $size: { '$ifNull': [`$${modelServiceMongoDB.modelName}`, []] } }, _id: 0 } },
            ]);

            return { data: results, size: results.length, total };
        } catch (ex) {
            console.log(`Exception getMatchFilterFirst ${modelServiceMongoDB.modelName} ${this.serviceName} ====> ${ex} `);
            throw new HttpException(`Exception getMatchFilterFirst ${modelServiceMongoDB.modelName} ${this.serviceName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    getDateFormatted(data: any): string {
        const date = new Date(data);
        const result = date.toLocaleDateString('th-TH', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
        });
        return result;
    }

    getTimeFormatted(data: any): string {
        const date = new Date(data);
        const result = date.toLocaleTimeString('th-TH', {
            hour: '2-digit',
            minute: '2-digit',
        });
        return result;
    }

    getDateTimeFormatted(data: any): string {
        const date = new Date(data);
        const resultDate = date.toLocaleDateString('th-TH', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
        });
        const resultTime = date.toLocaleTimeString('th-TH', {
            hour: '2-digit',
            minute: '2-digit',
        });
        return `${resultDate} ${resultTime}`;
    }

    compareHash(password: string, hash: string): boolean {
        return bcrypt.compareSync(password, hash);
    }

    async hashPassword(password: string): Promise<string> {
        return await bcrypt.hash(password, this.BCRYPT_HASH_ROUND);
    }

    async deleteFileMinIO(url: string) {
        return await firstValueFrom(this._httpService.delete(`${process.env.MINIO_URL}/${url}`));
    }
}
