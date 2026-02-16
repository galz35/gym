import { Controller, Get, Post, Body, Query, UseGuards, Request } from '@nestjs/common';
import { SyncService } from './sync.service';
import { PushSyncDto } from './dto/push-sync.dto';
import { PullSyncDto } from './dto/pull-sync.dto';
import { AuthGuard } from '@nestjs/passport';

@UseGuards(AuthGuard('jwt'))
@Controller('sync')
export class SyncController {
    constructor(private readonly syncService: SyncService) { }

    @Get('pull')
    async pull(@Request() req, @Query() query: PullSyncDto) {
        return this.syncService.pull(req.user.empresaId, query);
    }

    @Post('push')
    async push(@Request() req, @Body() body: PushSyncDto) {
        return this.syncService.push(req.user.empresaId, req.user.userId, body);
    }
}
