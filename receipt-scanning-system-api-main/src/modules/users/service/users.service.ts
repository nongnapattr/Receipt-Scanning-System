import { UntilityService } from './../../shared/services/untility.service';
import { MongoCRUD } from './../../shared/mongo-curd';
import { Model } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { UserModel } from '../model/user.model';
import * as _ from 'lodash';

@Injectable()
export class UsersService extends MongoCRUD<UserModel> {
    constructor(
        @InjectModel('users') public model: Model<UserModel>,
        private readonly _untility: UntilityService,
    ) {
        super(model);
    }

    async findByUsername(username: string) {
        try {
            return await this._model.findOne({ user_username: username }).exec();
        } catch (ex) {
            throw new HttpException(`Exception findByUsername ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    async findByEmailOrUsername(email: string) {
        try {
            return await this._model.findOne({ $or: [{ user_email: email }, { user_username: email }] }).exec();
        } catch (ex) {
            throw new HttpException(`Exception findByEmail ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }

    async create(data: UserModel) {
        try {
            data.user_username = data.user_username.trim();
            data.user_password = data.user_password.trim();
            data.user_password = await this._untility.hashPassword(data.user_password);
            return await new this._model(data).save();
        } catch (ex) {
            throw new HttpException(
                `Exception create ${this.modelName} ====> ${ex}`,
                HttpStatus.BAD_REQUEST,
            );
        }
    }

    async update(userId: string, data: UserModel): Promise<any> {
        try {
            const user = await this.findOne(userId);
            if (data.user_username !== undefined) {
                data.user_username = data.user_username.trim();
            }
            if (user.user_password !== data.user_password && data.user_password !== undefined) {
                if (data.user_password !== '') {
                    data.user_password = data.user_password.trim();
                    data.user_password = await this._untility.hashPassword(data.user_password);
                } else {
                    delete data.user_password;
                }
            }
            return await this._model.findByIdAndUpdate(userId, data, { new: true });
        } catch (ex) {
            throw new HttpException(`Exception update ${this.modelName} ====> ${ex}`, HttpStatus.BAD_REQUEST);
        }
    }
}
