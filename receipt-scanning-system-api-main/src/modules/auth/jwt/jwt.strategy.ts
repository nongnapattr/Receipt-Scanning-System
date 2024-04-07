import { JwtPayload } from './jwt-payload.inteface';
import { SECRET_KEY } from './secret-key';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable } from '@nestjs/common';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
    constructor() {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            secretOrKey: SECRET_KEY.secret,
        });
    }

    async validate(payload: JwtPayload) {
        return {
            user_id: payload.user_id,
            user_username: payload.user_username,
        };
    }
}