import { UntilityService } from '../../shared/services/untility.service';
import { JwtService } from '@nestjs/jwt';
import { UserModel } from '../../users/model/user.model';
import { UsersService } from '../../users/service/users.service';
import { JwtPayload } from '../jwt/jwt-payload.inteface';
import { HttpException, Injectable, HttpStatus } from '@nestjs/common';

@Injectable()
export class AuthService {
    public serviceName = 'AuthService';
    constructor(
        private readonly _users: UsersService,
        private readonly _jwtService: JwtService,
        private readonly _untility: UntilityService,
    ) { }

    async validateUser(username: string, password: string): Promise<UserModel> {
        username.trim();
        username.toLowerCase();
        const user = await this._users.findByUsername(username);
        if (!user) {
            throw new HttpException('ไม่พบชื่อผู้ใช้ในระบบ', HttpStatus.FORBIDDEN);
        }

        if (!this._untility.compareHash(password, user.user_password)) {
            throw new HttpException('กรุณาตรวจชื่อผู้ใช้กับรหัสผ่านอีกครั้ง', HttpStatus.FORBIDDEN);
        }
        return user;
    }

    async login(user: UserModel) {
        const payload: JwtPayload = {
            user_id: user['_id'].toString(),
            user_username: user.user_username,
        };
        return {
            access_token: this._jwtService.sign(payload)
        }
    }
}
