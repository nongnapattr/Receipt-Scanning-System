import { Module } from '@nestjs/common';
import { ReceiptsController } from './controller/receipts.controller';
import { ReceiptsService } from './service/receipts.service';
import { MongooseModule } from '@nestjs/mongoose';
import { ReceiptSchema } from './schema/receipt.schema';
import { SharedModule } from '../shared/shared.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'receipts', schema: ReceiptSchema },
    ]),
    SharedModule,
  ],
  controllers: [ReceiptsController],
  providers: [ReceiptsService],
  exports: [ReceiptsService]
})
export class ReceiptsModule { }
