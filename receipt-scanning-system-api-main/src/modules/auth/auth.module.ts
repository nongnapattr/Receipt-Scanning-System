import { Module } from '@nestjs/common';
import { AuthController } from './controller/auth.controller';
import { UsersModule } from '../users/users.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { AuthService } from './service/auth.service';
import { APP_GUARD } from '@nestjs/core';
import { JwtAuthGuard } from './jwt/jwt-auth.guard';
import { LocalStrategy } from './jwt/local.strategy';
import { JwtStrategy } from './jwt/jwt.strategy';
import { SharedModule } from '../shared/shared.module';
import { SECRET_KEY } from './jwt/secret-key';

@Module({
  imports: [
    UsersModule,
    PassportModule.register({ session: true }),
    JwtModule.register({
      secret: SECRET_KEY.secret,
      signOptions: { expiresIn: '7d' }
    }),
    SharedModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    LocalStrategy,
    JwtStrategy,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard
    }
  ],
  exports: [
    AuthService,
    JwtModule
  ]
})
export class AuthModule { }
