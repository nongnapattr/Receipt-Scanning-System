import { Public } from '../../auth/jwt/jwt-auth.guard';
import { Controller, Get, Param, Post, Body, Put, Delete, Req, HttpStatus, HttpException } from '@nestjs/common';
import { UsersService } from '../service/users.service';
import { UserModel } from '../model/user.model';


@Controller('users')
export class UsersController {
    constructor(
        private _users: UsersService,
    ) {
        this.checkDefaultUser();
    }

    async checkDefaultUser() {
        const { total } = await this._users.findAll();
        if (total === 0) {
            await this._users.create({ user_username: 'admin', user_password: 'admin' });
        }
    }

    @Get()
    async findAll(@Req() req: any) {
        return await this._users.findAll(req.query);
    }

    @Get(':userId')
    async findOne(@Param('userId') userId: string) {
        return await this._users.findOne(userId);
    }

    @Public()
    @Post()
    async create(@Body() data: UserModel) {
        data.user_username.trim();
        data.user_username.toLowerCase();
        if (!/^[a-z0-9]*$/.test(data.user_username)) {
            throw new HttpException(`ชื่อผู้ใช้ต้องเป็นภาษาอังกฤษและตัวเลขเท่านั้น`, HttpStatus.BAD_REQUEST);
        }
        const result = await this._users.findByUsername(data.user_username);
        if (!result) {
            return await this._users.create(data);
        } else {
            throw new HttpException(`มีชื่อผู้ใช้งานนี้ซ้ำในระบบ`, HttpStatus.BAD_REQUEST);
        }
    }

    @Put(':userId')
    async update(@Param('userId') userId: string, @Body() data: UserModel) {
        return await this._users.update(userId, data);;
    }

    @Delete(':userId')
    async delete(@Param('userId') userId: string) {
        return await this._users.delete(userId);
    }
}
