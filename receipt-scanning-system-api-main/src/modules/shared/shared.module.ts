import { UntilityService } from './services/untility.service';
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [HttpModule],
  providers: [UntilityService],
  exports: [UntilityService],
})
export class SharedModule { }
