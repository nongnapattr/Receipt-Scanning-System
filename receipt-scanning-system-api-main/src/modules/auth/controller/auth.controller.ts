import { AuthService } from '../service/auth.service';
import { LocalAuthGuard } from '../jwt/local-auth.guard';
import { Controller, Get, HttpCode, Post, Req, UseGuards, HttpStatus } from '@nestjs/common';
import { JwtAuthGuard, Public } from '../jwt/jwt-auth.guard';

@Controller('auth')
export class AuthController {

    constructor(
        private _authService: AuthService
    ) { }

    @Public()
    @UseGuards(LocalAuthGuard)
    @HttpCode(HttpStatus.OK)
    @Post('login')
    async login(@Req() req) {
        return await this._authService.login(req.user);
    }

    @UseGuards(JwtAuthGuard)
    @Get('profile')
    getProfile(@Req() req) {
        return req.user;
    }
}
