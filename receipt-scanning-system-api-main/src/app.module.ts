import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { SharedModule } from './modules/shared/shared.module';
import * as dotenv from 'dotenv';
import { APP_FILTER } from '@nestjs/core';
import { HttpExceptionFilter } from './modules/shared/http-exception.filter';
import { MongooseModule } from '@nestjs/mongoose';
import { ReceiptsModule } from './modules/receipts/receipts.module';

dotenv.config();
const options: any = {
  user: process.env.DB_USER,
  pass: process.env.DB_PASS,
  useNewUrlParser: true,
  useUnifiedTopology: true,
};

@Module({
  imports: [
    MongooseModule.forRoot(process.env.DB_URL, options),
    AuthModule,
    UsersModule,
    SharedModule,
    ReceiptsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    }
  ],
})
export class AppModule { }
